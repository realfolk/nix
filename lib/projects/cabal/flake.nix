{
  description = "A flake for Haskell projects managed with Cabal.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    projectLib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = { self, nixpkgs, projectLib, ... }:
    let
      id = "cabal";

      defineProject =
        { groupName
        , projectName
        , srcDir
        , buildDir
        , buildArtifactsDir
        , components ? [ ]
        , ...
        }:
        { inherit components; } // projectLib.lib.defineProject {
          inherit
            groupName
            projectName
            srcDir
            buildDir
            buildArtifactsDir;
        };

      make = { system, haskellPackages, project, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          cabalInstallPkg = haskellPackages.cabal-install;

          makeCommand = args: projectLib.lib.makeCommand (args // {
            inherit project;
            writeShellScriptBin = pkgs.writeShellScriptBin;
          });

          # COMMANDS

          cabal = makeCommand {
            name = "${id}-cabal";
            script = ''
              cd "${project.srcPath}"
              ${cabalInstallPkg}/bin/cabal "$@";
            '';
          };

          commands = {
            inherit cabal;
          };

          combinedCommandsPackage = pkgs.symlinkJoin {
            name = "${id}-commands-${project.groupName}-${project.projectName}";
            paths = builtins.map ({ package, ... }: package) (builtins.attrValues commands);
          };
        in
        {
          inherit commands combinedCommandsPackage;
        };
    in
    {
      lib = {
        inherit id defineProject make;
        shellHook = ghc: ''
          export NIX_GHC="${ghc}/bin/ghc"
          export NIX_GHCPKG="${ghc}/bin/ghc-pkg"
          export NIX_GHC_DOCDIR="${ghc}/share/doc/ghc/html"
          # Export the GHC lib dir to the environment
          # so ghcide knows how to source package dependencies.
          export NIX_GHC_LIBDIR="$(${ghc}/bin/ghc --print-libdir)"
        '';
      };
    };
}
