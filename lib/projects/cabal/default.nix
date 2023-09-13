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
  shellHook = ghc: ''
    export NIX_GHC="${ghc}/bin/ghc"
    export NIX_GHCPKG="${ghc}/bin/ghc-pkg"
    export NIX_GHC_DOCDIR="${ghc}/share/doc/ghc/html"
    # Export the GHC lib dir to the environment
    # so ghcide knows how to source package dependencies.
    export NIX_GHC_LIBDIR="$(${ghc}/bin/ghc --print-libdir)"
  '';
}
