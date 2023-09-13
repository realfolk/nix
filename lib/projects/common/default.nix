# Useful for all projects.

{ symlinkJoin, writeShellScriptBin }:
let
  id = "common";

  lib = import ../lib { inherit writeShellScriptBin; };

  make = { project }:
    let
      makeCommand = lib.makeCommand project;

      mkdirSrc = makeCommand {
        name = "${id}-mkdir-src";
        script = ''
          mkdir -p "${project.srcPath}"
        '';
      };

      pwdSrc = makeCommand {
        name = "${id}-pwd-src";
        script = ''
          echo "${project.srcPath}"
        '';
      };

      pwdBuild = makeCommand {
        name = "${id}-pwd-build";
        script = ''
          echo "${project.buildPath}"
        '';
      };

      cdSrc = makeCommand {
        name = "${id}-cd-src";
        script = ''
          cd "${project.srcPath}"
        '';
      };

      cdBuild = makeCommand {
        name = "${id}-cd-build";
        script = ''
          cd "${project.buildPath}"
        '';
      };

      lsSrc = makeCommand {
        name = "${id}-ls-src";
        script = ''
          ls "${project.srcPath}" "$@"
        '';
      };

      lsBuild = makeCommand {
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

      combinedCommandsPackage = symlinkJoin {
        name = "${id}-commands-${project.groupName}-${project.projectName}";
        paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
      };
    in
    { inherit commands combinedCommandsPackage; };
in
{
  inherit id make;
  inherit (lib) defineProject;
}
