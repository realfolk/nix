{
  description = "Packages and shells for working on Real Folk's Nix files.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";

    neovim = {
      url = "github:realfolk/nix?dir=lib/packages/neovim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flakeUtils.follows = "flakeUtils";
      };
    };

    ranger = {
      url = "github:realfolk/nix?dir=lib/packages/ranger";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flakeUtils.follows = "flakeUtils";
      };
    };

    rnixLsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakeUtils,
    neovim,
    ranger,
    rnixLsp,
    ...
  }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          rnixLsp = rnixLsp.defaultPackage.${system};
          neovim = neovim.packages.${system}.default;
          ranger = ranger.packages.${system}.default;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.silver-searcher # ag
            pkgs.fzf
            self.packages.${system}.rnixLsp
            self.packages.${system}.neovim
            self.packages.${system}.ranger
          ];
          shellHook = ''
            # Load ~/.bashrc if it exists
            test -f ~/.bashrc && source ~/.bashrc

            # Source .env file if present
            test -f "$PROJECT/.env" && source .env

            # Ignore files specified in .gitignore when using fzf
            # -t only searches text files and includes empty files
            export FZF_DEFAULT_COMMAND="ag -tl"

            # Initialize $PROJECT environment variable
            export PROJECT="$PWD"
          '';
        };
      });
}
