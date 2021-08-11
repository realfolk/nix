let

systemPkgs = import <nixpkgs> {};

in

systemPkgs.fetchFromGitHub {
  owner = "nixos";
  repo = "nixpkgs";
  rev = "c6aa7bdae0143c41043968a3abd9a9727a6cdf5a";
  sha256 = "17gvpk7kga75ah6xwgzl514zbmcm9vxx44ad521jb84kcdkbzwng";
}
