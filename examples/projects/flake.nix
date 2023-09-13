{
  description = "An example of a development shell using Real Folk's project helpers.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=23.05";
    flakeUtils.url = "github:numtide/flake-utils";

    realfolkNix.url = "path:../..";
    # NOTE: Projects external to this repository would use
    #       the following flake reference instead:
    #
    #   realfolkNix.url = "github:realfolk/nix";
  };

  outputs =
    { self
    , nixpkgs
    , flakeUtils
    , realfolkNix
    , ...
    }:
    flakeUtils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      realfolkNixPkgs = realfolkNix.packages.${system};

      nodejs = realfolkNixPkgs.nodejs;

      neovim = realfolkNixPkgs.neovim;
      tmux = realfolkNixPkgs.tmux;
      ranger = realfolkNixPkgs.ranger;

      realfolkNixLib = realfolkNix.lib.${system};

      elmPackages = realfolkNixLib.elmPackages;
      haskellPackages = realfolkNixLib.haskellPackages;

      cabalProject = realfolkNixLib.cabalProject;
      commonProject = realfolkNixLib.commonProject;
      elmProject = realfolkNixLib.elmProject;
      haskellProject = realfolkNixLib.haskellProject;
      nodeProject = realfolkNixLib.nodeProject;
      rustProject = realfolkNixLib.rustProject;
      staticProject = realfolkNixLib.staticProject;

      dirs = {
        srcDir = "$PROJECT/src";
        buildDir = "$PROJECT/build";
        buildArtifactsDir = "$PROJECT/artifacts";
      };

      defineCabalProject = cabalProject.defineProject dirs;

      defineCommonProject = commonProject.defineProject dirs;

      defineElmProject = elmProject.defineProject dirs;

      defineHaskellProject = haskellProject.defineProject dirs;

      defineNodeProject = nodeProject.defineProject dirs;

      defineRustProject = rustProject.defineProject dirs;

      defineStaticProject = staticProject.defineProject dirs;

      testCabalProjectDefinition = {
        groupName = "group";
        projectName = "testcabal";
      };

      testCabalProjectCabal = cabalProject.make {
        project = defineCabalProject testCabalProjectDefinition;
        inherit haskellPackages;
      };

      testCabalProjectCommon = commonProject.make {
        project = defineCommonProject testCabalProjectDefinition;
      };

      testElmProjectDefinition = {
        groupName = "group";
        projectName = "testelm";
        entryPoints = {
          main = "Main.elm";
        };
      };

      testElmProjectElm = elmProject.make {
        project = defineElmProject testElmProjectDefinition;
      };

      testElmProjectCommon = commonProject.make {
        project = defineCommonProject testElmProjectDefinition;
      };

      testHaskellProjectDefinition = {
        groupName = "group";
        projectName = "testhaskell";
        executables = {
          main = "Main.hs";
        };
        haskellDependencies = p: with p; [
          aeson
          cryptonite
        ];
      };

      testHaskellProjectHaskell = haskellProject.make {
        project = defineHaskellProject testHaskellProjectDefinition;
        inherit haskellPackages;
      };

      testHaskellProjectCommon = commonProject.make {
        project = defineCommonProject testHaskellProjectDefinition;
      };

      testNodeProjectDefinition = {
        groupName = "group";
        projectName = "testnode";
        executables = {
          index = "index.js";
        };
      };

      testNodeProjectNode = nodeProject.make {
        project = defineNodeProject testNodeProjectDefinition;
        nodeInterpreter = nodejs;
      };

      testNodeProjectCommon = commonProject.make {
        project = defineCommonProject testNodeProjectDefinition;
      };

      testRustProjectDefinition = {
        groupName = "group";
        projectName = "testrust";
      };

      testRustProjectRust = rustProject.make {
        project = defineRustProject testRustProjectDefinition;
      };

      testRustProjectCommon = commonProject.make {
        project = defineCommonProject testRustProjectDefinition;
      };

      testStaticProjectDefinition = {
        groupName = "group";
        projectName = "teststatic";
      };

      testStaticProjectStatic = staticProject.make {
        project = defineStaticProject testStaticProjectDefinition;
      };

      testStaticProjectCommon = commonProject.make {
        project = defineCommonProject testStaticProjectDefinition;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          neovim
          ranger
          tmux

          # Cabal
          testCabalProjectCabal.combinedCommandsPackage
          testCabalProjectCommon.combinedCommandsPackage

          # Elm
          elmPackages.elm
          elmPackages.elm-language-server
          elmPackages.elm-format
          elmPackages.elm-test
          testElmProjectElm.combinedCommandsPackage
          testElmProjectCommon.combinedCommandsPackage

          # Haskell
          haskellPackages.ghc
          haskellPackages.haskell-language-server
          testHaskellProjectHaskell.combinedCommandsPackage
          testHaskellProjectCommon.combinedCommandsPackage

          # Node.js
          nodejs
          testNodeProjectNode.combinedCommandsPackage
          testNodeProjectCommon.combinedCommandsPackage

          # Rust
          testRustProjectRust.combinedCommandsPackage
          testRustProjectCommon.combinedCommandsPackage

          # Static Assets
          testStaticProjectStatic.combinedCommandsPackage
          testStaticProjectCommon.combinedCommandsPackage
        ];

        shellHook = ''
          test -f ~/.bashrc && source ~/.bashrc
          export PROJECT="$PWD"
          ${testCabalProjectCommon.commands.mkdirSrc.bin}
          ${testElmProjectCommon.commands.mkdirSrc.bin}
          ${testHaskellProjectCommon.commands.mkdirSrc.bin}
          ${testHaskellProjectHaskell.commands.hieYaml.bin}
          ${testNodeProjectCommon.commands.mkdirSrc.bin}
          ${testRustProjectCommon.commands.mkdirSrc.bin}
          ${testStaticProjectCommon.commands.mkdirSrc.bin}
        '';
      };
    });
}
