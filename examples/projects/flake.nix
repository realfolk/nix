{
  description = "An example of a development shell using Real Folk's project flakes.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flakeUtils.url = "github:numtide/flake-utils";

    neovim = {
      url = "github:realfolk/nix?dir=lib/packages/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeUtils.follows = "flakeUtils";
    };

    tmux = {
      url = "github:realfolk/nix?dir=lib/packages/tmux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeUtils.follows = "flakeUtils";
    };

    ranger = {
      url = "github:realfolk/nix?dir=lib/packages/ranger";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeUtils.follows = "flakeUtils";
    };

    elmPackages.url = "github:realfolk/nix?dir=lib/projects/elm/packages";
    haskellPackages.url = "github:realfolk/nix?dir=lib/projects/haskell/packages/ghc-9.2.1";
    nodeInterpreter.url = "github:realfolk/nix?dir=lib/projects/node/interpreter/node-17";

    commonProject = {
      url = "github:realfolk/nix?dir=lib/projects/common";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elmProject = {
      url = "github:realfolk/nix?dir=lib/projects/elm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haskellProject = {
      url = "github:realfolk/nix?dir=lib/projects/haskell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    staticProject = {
      url = "github:realfolk/nix?dir=lib/projects/static";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nodeProject = {
      url = "github:realfolk/nix?dir=lib/projects/node";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    projectLib.url = "github:realfolk/nix?dir=lib/projects/lib";
  };

  outputs = {
      self,
      nixpkgs,
      flakeUtils,
      neovim,
      tmux,
      ranger,
      elmPackages,
      haskellPackages,
      nodeInterpreter,
      commonProject,
      elmProject,
      haskellProject,
      nodeProject,
      staticProject,
      projectLib,
      ...
    }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        config = {
          srcDir = "$PROJECT/src";
          buildDir = "$PROJECT/build";
          buildArtifactsDir = "$PROJECT/artifacts";
        };

        defineProject = args: projectLib.lib.defineProject (args // config);

        defineElmProject = args: elmProject.lib.defineProject (args // config);

        defineHaskellProject = args: haskellProject.lib.defineProject (args // config);

        defineStaticProject = args: staticProject.lib.defineProject (args // config);

        defineNodeProject = args: nodeProject.lib.defineProject (args // config);

        testElmProjectDefinition = {
          groupName = "group";
          projectName = "testelm";
          entryPoints = {
            main = "Main.elm";
          };
        };

        testElmProjectElm = elmProject.lib.make {
          inherit system;
          elmPackages = elmPackages.packages.${system};
          project = defineElmProject testElmProjectDefinition;
        };

        testElmProjectCommon = commonProject.lib.make {
          inherit system;
          project = defineProject testElmProjectDefinition;
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

        testHaskellProjectHaskell = haskellProject.lib.make {
          inherit system;
          haskellPackages = haskellPackages.packages.${system};
          project = defineHaskellProject testHaskellProjectDefinition;
        };

        testHaskellProjectCommon = commonProject.lib.make {
          inherit system;
          project = defineProject testHaskellProjectDefinition;
        };

        testStaticProjectDefinition = {
          groupName = "group";
          projectName = "teststatic";
        };

        testStaticProjectStatic = staticProject.lib.make {
          inherit system;
          project = defineStaticProject testStaticProjectDefinition;
        };

        testStaticProjectCommon = commonProject.lib.make {
          inherit system;
          project = defineProject testStaticProjectDefinition;
        };

        testNodeProjectDefinition = {
          groupName = "group";
          projectName = "testnode";
          executables = {
            index = "index.js";
          };
        };

        testNodeProjectNode = nodeProject.lib.make {
          inherit system;
          nodeInterpreter = nodeInterpreter.packages.${system}.default;
          project = defineNodeProject testNodeProjectDefinition;
        };

        testNodeProjectCommon = commonProject.lib.make {
          inherit system;
          project = defineProject testNodeProjectDefinition;
        };
      in
      {
        packages = {
          neovim = neovim.packages.${system}.default;
          tmux = tmux.packages.${system}.default;
          ranger = ranger.packages.${system}.default;
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            self.packages.${system}.neovim
            self.packages.${system}.tmux
            self.packages.${system}.ranger
            #Elm
            elmPackages.packages.${system}.elm
            elmPackages.packages.${system}.elm-language-server
            elmPackages.packages.${system}.elm-format
            elmPackages.packages.${system}.elm-test
            testElmProjectElm.combinedCommandsPackage
            testElmProjectCommon.combinedCommandsPackage
            #Haskell
            haskellPackages.packages.${system}.ghc
            haskellPackages.packages.${system}.haskell-language-server
            testHaskellProjectHaskell.combinedCommandsPackage
            testHaskellProjectCommon.combinedCommandsPackage
            #Static Assets
            testStaticProjectStatic.combinedCommandsPackage
            testStaticProjectCommon.combinedCommandsPackage
            #Node.js
            nodeInterpreter.packages.${system}.default
            testNodeProjectNode.combinedCommandsPackage
            testNodeProjectCommon.combinedCommandsPackage
          ];
          shellHook = ''
            test -f ~/.bashrc && source ~/.bashrc
            export PROJECT="$PWD"
            ${testElmProjectCommon.commands.mkdirSrc.bin}
            ${testHaskellProjectCommon.commands.mkdirSrc.bin}
            ${testHaskellProjectHaskell.commands.hieYaml.bin}
            ${testStaticProjectCommon.commands.mkdirSrc.bin}
            ${testNodeProjectCommon.commands.mkdirSrc.bin}
          '';
        };
      });
}
