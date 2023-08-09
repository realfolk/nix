{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
    sha3sum.url = "github:realfolk/nix?dir=lib/packages/sha3sum";
  };

  outputs =
    { self
    , nixpkgs
    , flakeUtils
    , sha3sum
    , ...
    }:
    flakeUtils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages = {
        default = pkgs.writeScriptBin "generate-ethereum-account" ''
          #! /usr/bin/env bash

          KECCAK_256SUM_BIN="${sha3sum.packages.${system}.default}/bin/keccak-256sum"

          ${builtins.readFile ./generate-ethereum-account.sh}
        '';
      };
    });
}
