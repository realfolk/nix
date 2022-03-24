{
  description = "A flake for all projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    projectLib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = { self, nixpkgs, projectLib, ... }:
    let
      id = "common";

      make = { system, project, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          makeCommand = args: projectLib.lib.makeCommand (args // {
            writeShellScriptBin = pkgs.writeShellScriptBin;
          });

          mkdirSrc = makeCommand {
            inherit project;
            name = "${id}-mkdir-src";
            script = ''
              mkdir -p "${project.srcPath}"
            '';
          };

          pwdSrc = makeCommand {
            inherit project;
            name = "${id}-pwd-src";
            script = ''
              echo "${project.srcPath}"
            '';
          };

          pwdBuild = makeCommand {
            inherit project;
            name = "${id}-pwd-build";
            script = ''
              echo "${project.buildPath}"
            '';
          };

          cdSrc = makeCommand {
            inherit project;
            name = "${id}-cd-src";
            script = ''
              cd "${project.srcPath}"
            '';
          };

          cdBuild = makeCommand {
            inherit project;
            name = "${id}-cd-build";
            script = ''
              cd "${project.buildPath}"
            '';
          };

          lsSrc = makeCommand {
            inherit project;
            name = "${id}-ls-src";
            script = ''
              ls "${project.srcPath}" "$@"
            '';
          };

          lsBuild = makeCommand {
            inherit project;
            name = "${id}-ls-build";
            script = ''
              ls "${project.buildPath}" "$@"
            '';
          };

          commands = {
            inherit
              mkdirSrc
              pwdSrc
              pwdBuild
              cdSrc
              cdBuild
              lsSrc
              lsBuild;
          };

          combinedCommandsPackage = pkgs.symlinkJoin {
            name = "${id}-commands-${project.groupName}-${project.projectName}";
            paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
          };
        in
        { inherit commands combinedCommandsPackage; };
    in
    {
      lib = { inherit id make; };
    };
}
