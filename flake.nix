{
  description = "Packages, apps and developer shells for working on Real Folk's projects.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=23.05";
    flake-utils.url = "github:numtide/flake-utils";
    rnixLsp.url = "github:nix-community/rnix-lsp";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , rnixLsp
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

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
        inherit generate-ethereum-account mosh neovim ranger screen tmux;
      };

      apps = {
        generate-ethereum-account = flake-utils.lib.mkApp { drv = self.packages.${system}.generate-ethereum-account; };
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.silver-searcher
          pkgs.fzf
          self.packages.${system}.rnixLsp
          neovim
          ranger
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
