{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
    libkeccakSrc = {
      url = "https://github.com/maandree/libkeccak/archive/refs/heads/master.zip";
      flake = false;
    };
    sha3sumSrc = {
      url = "https://github.com/maandree/sha3sum/archive/refs/heads/master.zip";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flakeUtils
    , libkeccakSrc
    , sha3sumSrc
    , ...
    }:
    flakeUtils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages = rec {
        libkeccak = pkgs.stdenv.mkDerivation {
          name = "libkeccak";
          src = libkeccakSrc;
          buildPhase = "make";
          installPhase = ''PREFIX="$out" make -e install'';
        };
        default = pkgs.stdenv.mkDerivation {
          name = "sha3sum";
          src = sha3sumSrc;
          buildInputs = [ libkeccak ];
          buildPhase = "make";
          installPhase = ''PREFIX="$out" make -e install'';
        };
      };
    });
}
