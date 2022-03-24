{
  description = "A flake for Node.js projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    projectLib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = { self, nixpkgs, projectLib, ... }:
    let
      id = "node";

      defineProject = {
        groupName,
        projectName,
        srcDir,
        buildDir,
        buildArtifactsDir,
        executables ? {},
        ...
      }:
        { inherit executables; } // projectLib.lib.defineProject {
          inherit
            groupName
            projectName
            srcDir
            buildDir
            buildArtifactsDir;
        };

      make = { system, nodeInterpreter, project, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          makeCommand = args: projectLib.lib.makeCommand (args // {
            inherit project;
            writeShellScriptBin = pkgs.writeShellScriptBin;
          });

          makeCommandsForExecutables = { name, makeScript }:
            pkgs.lib.attrsets.mapAttrs'
              (executableName: mainFile:
                let
                  scriptName = "${name}-${executableName}";
                in
                pkgs.lib.attrsets.nameValuePair scriptName (makeCommand {
                  name = scriptName;
                  script = makeScript executableName mainFile;
                }))
              project.executables;

          makeBuildDir = dirName: "${project.buildPath}/${id}/${dirName}";
          makeBuildTarget = { dirName, targetName }: "${makeBuildDir dirName}/${targetName}";
          makeBuildTargetJs = dirName: makeBuildTarget { inherit dirName; targetName = "out.js"; };

          # COMMANDS

          node = makeCommand {
            name = "${id}-node";
            script = ''
              cd "${project.srcPath}"
              ${nodeInterpreter}/bin/node "$@"
            '';
          };

          npm = makeCommand {
            name = "${id}-npm";
            script = ''
              cd "${project.srcPath}"
              ${nodeInterpreter}/bin/npm "$@"
            '';
          };

          npx = makeCommand {
            name = "${id}-npx";
            script = ''
              cd "${project.srcPath}"
              ${nodeInterpreter}/bin/npx "$@"
            '';
          };

          run = makeCommandsForExecutables {
            name = "${id}-run";
            makeScript = executableName: mainFile:
              "${node.bin} ${mainFile}";
          };

          commands = { inherit node npm npx; } // run;

          combinedCommandsPackage = pkgs.symlinkJoin {
            name = "${id}-commands-${project.groupName}-${project.projectName}";
            paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
          };
        in
        { inherit commands combinedCommandsPackage; };
    in
    {
      lib = { inherit id defineProject make; };
    };
}
