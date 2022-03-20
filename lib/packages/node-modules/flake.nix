{
  description = "Custom node packages built with node2nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        nodePackages = import ./default.nix { pkgs = nixpkgs.legacyPackages.${system}; };

        prettierd = nodePackages."@fsouza/prettierd";
      in
      {
        packages = {
          inherit prettierd;
        };
      });
} 
