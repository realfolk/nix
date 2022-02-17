{
  description = "Common commands for projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    project-lib.url = "path:./lib/projects/lib";
  };

  outputs = { self, nixpkgs, flake-utils, project-lib, project, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        makeCommand = args: project-lib.lib.makeCommand (args // {
          writeShellScriptBin = pkgs.writeShellScriptBin;
        });

        id = "common";

        mkdir-src = makeCommand {
          inherit project;
          name = "${id}-mkdir-src";
          script = ''
            mkdir -p "${project.srcPath}"
          '';
        };

        pwd-src = makeCommand {
          inherit project;
          name = "${id}-pwd-src";
          script = ''
            echo "${project.srcPath}"
          '';
        };

        pwd-build = makeCommand {
          inherit project;
          name = "${id}-pwd-build";
          script = ''
            echo "${project.buildPath}"
          '';
        };

        cd-src = makeCommand {
          inherit project;
          name = "${id}-cd-src";
          script = ''
            cd "${project.srcPath}"
          '';
        };

        cd-build = makeCommand {
          inherit project;
          name = "${id}-cd-build";
          script = ''
            cd "${project.buildPath}"
          '';
        };

        ls-src = makeCommand {
          inherit project;
          name = "${id}-ls-src";
          script = ''
            ls "${project.srcPath}" "$@"
          '';
        };

        ls-build = makeCommand {
          inherit project;
          name = "${id}-ls-build";
          script = ''
            ls "${project.buildPath}" "$@"
          '';
        };
      in
      {
        lib = {
          inherit id;
          commands = {
            inherit
              mkdir-src
              pwd-src
              pwd-build
              cd-src
              cd-build
              ls-src
              ls-build;
          };
        };

        packages = builtins.mapAttrs (name: { package, ... }: package) self.lib.${system}.commands;

        defaultPackage = pkgs.symlinkJoin {
          name = "${id}-commands-${project.groupName}-${project.projectName}";
          paths = builtins.attrValues self.packages.${system};
        };
      });
}
