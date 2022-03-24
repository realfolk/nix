{
  description = "An example of a development shell using Real Folk's project flakes.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    neovim = {
      url = "github:realfolk/nix?dir=lib/packages/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    tmux = {
      url = "github:realfolk/nix?dir=lib/packages/tmux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ranger = {
      url = "github:realfolk/nix?dir=lib/packages/ranger";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    elm-packages.url = "github:realfolk/nix?dir=lib/projects/elm/packages";

    test-elm-project-definition = {
      url = "github:realfolk/nix?dir=examples/projects/project-flakes/test-elm-project";
    };

    elm-project = {
      url = "github:realfolk/nix?dir=lib/projects/elm";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    test-elm-project-common = {
      url = "github:realfolk/nix?dir=lib/projects/common";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.project.follows = "test-elm-project-definition";
    };

    test-haskell-project-definition.url = "github:realfolk/nix?dir=examples/projects/project-flakes/test-haskell-project";

    haskell-packages.url = "github:realfolk/nix?dir=lib/projects/haskell/packages/ghc-9.2.1";

    test-haskell-project = {
      url = "github:realfolk/nix?dir=lib/projects/haskell/make";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.project.follows = "test-haskell-project-definition";
      inputs.haskell-packages.follows = "haskell-packages";
    };

    test-haskell-project-common = {
      url = "github:realfolk/nix?dir=lib/projects/common";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.project.follows = "test-haskell-project-definition";
    };

    test-static-project-definition.url = "github:realfolk/nix?dir=examples/projects/project-flakes/test-static-project";

    test-static-project = {
      url = "github:realfolk/nix?dir=lib/projects/static/make";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.project.follows = "test-static-project-definition";
    };

    test-static-project-common = {
      url = "github:realfolk/nix?dir=lib/projects/common";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.project.follows = "test-static-project-definition";
    };

    node-interpreter.url = "github:realfolk/nix?dir=lib/projects/node/interpreter/node-17";

    test-node-project-definition = {
      url = "github:realfolk/nix?dir=examples/projects/project-flakes/test-node-project";
    };

    test-node-project = {
      url = "github:realfolk/nix?dir=lib/projects/node/make";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.node-interpreter.follows = "node-interpreter";
      inputs.project.follows = "test-node-project-definition";
    };

    test-node-project-common = {
      url = "github:realfolk/nix?dir=lib/projects/common";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.project.follows = "test-node-project-definition";
    };
  };

  outputs = {
      self,
      nixpkgs,
      flake-utils,
      neovim,
      tmux,
      ranger,
      elm-packages,
      elm-project,
      test-elm-project-common,
      haskell-packages,
      test-haskell-project,
      test-haskell-project-common,
      test-static-project,
      test-static-project-common,
      node-interpreter,
      test-node-project,
      test-node-project-common,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        test-elm-project =
          elm-project.lib.make {
            inherit system;
            elmPackages = elm-packages.packages.${system};
            project = elm-project.lib.defineProject {
              groupName = "group";
              projectName = "testelm";
              srcDir = "$PROJECT/src";
              buildDir = "$PROJECT/build";
              buildArtifactsDir = "$PROJECT/artifacts";
              entryPoints = {
                main = "Main.elm";
              };
            };
          };
      in
      {
        packages = {
          neovim = neovim.defaultPackage.${system};
          tmux = tmux.defaultPackage.${system};
          ranger = ranger.defaultPackage.${system};
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            self.packages.${system}.neovim
            self.packages.${system}.tmux
            self.packages.${system}.ranger
            #Elm
            elm-packages.packages.${system}.elm
            elm-packages.packages.${system}.elm-language-server
            elm-packages.packages.${system}.elm-format
            elm-packages.packages.${system}.elm-test
            test-elm-project.combinedCommandsPackage
            test-elm-project-common.defaultPackage.${system}
            #Haskell
            haskell-packages.packages.${system}.ghc
            haskell-packages.packages.${system}.haskell-language-server
            test-haskell-project.defaultPackage.${system}
            test-haskell-project-common.defaultPackage.${system}
            #Static Assets
            test-static-project.defaultPackage.${system}
            test-static-project-common.defaultPackage.${system}
            #Node.js
            node-interpreter.defaultPackage.${system}
            test-node-project.defaultPackage.${system}
            test-node-project-common.defaultPackage.${system}
          ];
          shellHook = ''
            test -f ~/.bashrc && source ~/.bashrc
            export PROJECT="$PWD"
            ${test-elm-project-common.lib.${system}.commands.mkdir-src.bin}
            ${test-haskell-project-common.lib.${system}.commands.mkdir-src.bin}
            ${test-haskell-project.lib.${system}.commands.hie-yaml.bin}
            ${test-static-project-common.lib.${system}.commands.mkdir-src.bin}
            ${test-node-project-common.lib.${system}.commands.mkdir-src.bin}
          '';
        };
      });
}
