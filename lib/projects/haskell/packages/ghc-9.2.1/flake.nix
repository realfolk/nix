{
  description = "Haskell packages for GHC 9.2.1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flakeUtils, ... }:
    flakeUtils.lib.eachDefaultSystem (system: {
      packages = nixpkgs.legacyPackages.${system}.haskell.packages.ghc921;
    });
}
