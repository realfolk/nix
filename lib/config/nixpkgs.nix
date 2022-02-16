let

systemPkgs = import <nixpkgs> {};

in

systemPkgs.fetchFromGitHub {
  owner = "nixos";
  repo = "nixpkgs";
  rev = "7ff1fdfc7834c3a616a1f70a4e70eaf78fdadb80";
  sha256 = "0qy0sg6j5yrjfslqjhx39h0ri9q4mdm3y4fviv6rb3233w8rkmjs";
}
