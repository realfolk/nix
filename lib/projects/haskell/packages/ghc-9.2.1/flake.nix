{
  description = "Haskell packages for GHC 9.2.1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = nixpkgs.legacyPackages.${system}.haskell.packages.ghc921;
    });
}
