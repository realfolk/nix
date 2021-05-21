let

systemPkgs = import <nixpkgs> {};

in

systemPkgs.fetchFromGitHub {
  owner = "nixos";
  repo = "nixpkgs";
  rev = "259e3fc46f986ff8502879d8a7408f82c9a19eb2";
  sha256 = "1d2k93zkzivfg7rkbiaj9psisq05vz2hvd4cq7rlpbfqicf607m3";
}
