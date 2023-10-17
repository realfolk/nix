# Useful for Haskell projects managed with Cabal.

{ symlinkJoin, writeShellScriptBin }:
let
  id = "cabal";

  lib = import ../lib { inherit writeShellScriptBin; };

  make = { project, haskellPackages }:
    let
      makeCommand = lib.makeCommand project;

      cabalInstallPkg = haskellPackages.cabal-install;

      cabal = makeCommand {
        name = "${id}-cabal";
        script = ''
          cd "${project.srcPath}"
          ${cabalInstallPkg}/bin/cabal "$@"
        '';
      };

      commands = {
        inherit cabal;
      };

      combinedCommandsPackage = symlinkJoin {
        name = "${id}-commands-${project.groupName}-${project.projectName}";
        paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
      };
    in
    {
      inherit commands combinedCommandsPackage;
    };
in
{
  inherit id make;
  inherit (lib) defineProject;
}
