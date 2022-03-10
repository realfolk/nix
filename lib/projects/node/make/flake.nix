{
  description = "Commands for Node.js projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    project-lib.url = "github:realfolk/nix?dir=lib/projects/lib";
    node-lib.url = "github:realfolk/nix?dir=lib/projects/node/lib";
  };

  outputs = { self, nixpkgs, flake-utils, project-lib, node-lib, node-interpreter, project, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        systemNodeJs = node-interpreter.defaultPackage.${system};

        id = node-lib.lib.id;

        makeCommand = args: project-lib.lib.makeCommand (args // {
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
            ${systemNodeJs}/bin/node "$@"
          '';
        };

        npm = makeCommand {
          name = "${id}-npm";
          script = ''
            cd "${project.srcPath}"
            ${systemNodeJs}/bin/npm "$@"
          '';
        };

        npx = makeCommand {
          name = "${id}-npx";
          script = ''
            cd "${project.srcPath}"
            ${systemNodeJs}/bin/npx "$@"
          '';
        };

        run = makeCommandsForExecutables {
          name = "${id}-run";
          makeScript = executableName: mainFile:
            "${node.bin} ${mainFile}";
        };
      in
      {
        lib = {
          commands = { inherit node npm npx; } // run;
        };

        packages = builtins.mapAttrs (name: { package, ... }: package) self.lib.${system}.commands;

        defaultPackage = pkgs.symlinkJoin {
          name = "${id}-commands-${project.groupName}-${project.projectName}";
          paths = builtins.attrValues self.packages.${system};
        };
      });
}
