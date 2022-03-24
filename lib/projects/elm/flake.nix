{
  description = "A flake for Elm projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    projectLib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = { self, nixpkgs, projectLib, ... }:
    let
      id = "elm";

      defineProject = {
        groupName,
        projectName,
        srcDir,
        buildDir,
        buildArtifactsDir,
        entryPoints ? {},
        ...
      }:
        { inherit entryPoints; } // projectLib.lib.defineProject {
          inherit
            groupName
            projectName
            srcDir
            buildDir
            buildArtifactsDir;
        };

      make = { system, elmPackages, project, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          makeCommand = args: projectLib.lib.makeCommand (args // {
            inherit project;
            writeShellScriptBin = pkgs.writeShellScriptBin;
          });

          makeCommandsForEntryPoints = { name, makeScript }:
            nixpkgs.lib.attrsets.mapAttrs'
              (entryPointName: mainFile:
                let
                  scriptName = "${name}-${entryPointName}";
                in
                nixpkgs.lib.attrsets.nameValuePair scriptName (makeCommand {
                  name = scriptName;
                  script = makeScript entryPointName mainFile;
                }))
              project.entryPoints;

          makeBuildDir = dirName: "${project.buildPath}/${id}/${dirName}";
          makeBuildTarget = { dirName, targetName }: "${makeBuildDir dirName}/${targetName}";
          makeBuildTargetJs = dirName: makeBuildTarget { inherit dirName; targetName = "out.js"; };

          # COMMANDS

          elm = makeCommand {
            name = "${id}-elm";
            script = ''
              cd "${project.srcPath}"
              ${elmPackages.elm}/bin/elm "$@"
            '';
          };

          build = makeCommandsForEntryPoints {
            name = "${id}-build";
            makeScript = (entryPointName: mainFile:
              let
                buildDir = makeBuildDir entryPointName;
                buildTarget = makeBuildTargetJs entryPointName;
              in ''
                echo "Removing old build directory: ${buildDir}"
                mkdir -p "${buildDir}"
                rm -rf "${buildDir}"
                ${elm.bin} make src/${mainFile} --output "${buildTarget}" "$@"
                echo "Successfully built entry point ${mainFile}: ${buildTarget}"
            '');
          };

          commands = { inherit elm; } // build;

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
