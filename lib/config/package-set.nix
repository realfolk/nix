let

systemPkgs = import <nixpkgs> {};
src = import ./nixpkgs.nix;

in

import src {}
