{ pkgs ? import <nixpkgs> {} }:

rec {

  config = {
    pkgs = import ./config/pinned-packages.nix { inherit (pkgs) fetchFromGitHub; };
  };

  helpers = {
    importPackage = path: import path { pkgs = config.pkgs; };
  };

  customPackages = {
    vim = importPackage ./custom-packages/vim/default.nix;
    screen = importPackage ./custom-packages/screen/default.nix;
  };

}
