{
  description = "Commands for Elm projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    project-lib.url = "github:realfolk/nix?dir=lib/projects/lib";
    elm-lib.url = "github:realfolk/nix?dir=lib/projects/elm/lib";
  };

  outputs = { self, nixpkgs, flake-utils, project-lib, elm-lib, elm-packages, project, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        systemElmPackages = elm-packages.packages.${system};

        id = elm-lib.lib.id;

        makeCommand = args: project-lib.lib.makeCommand (args // {
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
            ${systemElmPackages.elm}/bin/elm "$@"
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
      in
      {
        lib = {
          commands = { inherit elm; } // build;
        };

        packages = builtins.mapAttrs (name: { package, ... }: package) self.lib.${system}.commands;

        defaultPackage = pkgs.symlinkJoin {
          name = "${id}-commands-${project.groupName}-${project.projectName}";
          paths = builtins.attrValues self.packages.${system};
        };
      });
}
