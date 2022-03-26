{
  description = "Haskell packages for GHC 9.2.1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flakeUtils, ... }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # Many haskell dependencies are usually marked as broken.
          config.allowBroken = true;
        };
      in
      {
        packages = pkgs.haskell.packages.ghc921;
      });
}
