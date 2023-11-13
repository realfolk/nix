{
  description = "Packages, apps, project helpers and developer shells for working on Real Folk's projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=23.05";
    flakeUtils.url = "github:numtide/flake-utils";

    haskellPackages = {
      url = "github:realfolk/nix?dir=lib/projects/haskell/packages/ghc-9.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeUtils.follows = "flakeUtils";
    };

    rnixLsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flakeUtils";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flakeUtils
    , haskellPackages
    , rnixLsp
    , ...
    }:
    flakeUtils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      elmPackages = pkgs.elmPackages;

      nodejs = pkgs.nodejs-18_x;

      generate-ethereum-account = pkgs.callPackage ./lib/packages/generate-ethereum-account {};
      mosh = pkgs.callPackage ./lib/packages/mosh {};
      neovim = pkgs.callPackage ./lib/packages/neovim {};
      ranger = pkgs.callPackage ./lib/packages/ranger {};
      screen = pkgs.callPackage ./lib/packages/screen {};
      tmux = pkgs.callPackage ./lib/packages/tmux {};
    in
    {
      packages = {
        rnixLsp = rnixLsp.defaultPackage.${system};
        inherit nodejs;
        inherit generate-ethereum-account mosh neovim ranger screen tmux;
      };

      apps = {
        generate-ethereum-account = flakeUtils.lib.mkApp { drv = self.packages.${system}.generate-ethereum-account; };
      };

      nixosModules = {
        apps = import ./nixos/modules/apps.nix;
        redirects = import ./nixos/modules/redirects.nix;
        secrets = import ./nixos/modules/secrets.nix;
        user = import ./nixos/modules/user.nix;
        volumes = import ./nixos/modules/volumes.nix;
      };

      lib = {
        inherit elmPackages;
        haskellPackages = haskellPackages.packages.${system};

        cabalProject = pkgs.callPackage ./lib/projects/cabal {};
        commonProject = pkgs.callPackage ./lib/projects/common {};

        elmProject = pkgs.callPackage ./lib/projects/elm {};
        elmBuilder = pkgs.callPackage ./lib/projects/elm/builder.nix {};

        haskellProject = pkgs.callPackage ./lib/projects/haskell {};
        nodeProject = pkgs.callPackage ./lib/projects/node {};
        rustProject = pkgs.callPackage ./lib/projects/rust {};
        staticProject = pkgs.callPackage ./lib/projects/static {};
      };

      devShells.default = pkgs.mkShell {
        packages = [
          neovim
          pkgs.fzf
          pkgs.silver-searcher
          ranger
          self.packages.${system}.rnixLsp
        ];

        shellHook = ''
          # Load ~/.bashrc if it exists
          test -f ~/.bashrc && source ~/.bashrc

          # Initialize $PROJECT environment variable
          export PROJECT="$PWD"

          # Source .env file if present
          test -f "$PROJECT/.env" && source .env

          # Ignore files specified in .gitignore when using fzf
          # -t only searches text files and includes empty files
          export FZF_DEFAULT_COMMAND="ag -tl"
        '';
      };
    });
}
