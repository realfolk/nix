let

systemPkgs = import <nixpkgs> {};

in

systemPkgs.fetchFromGitHub {
  owner = "nixos";
  repo = "nixpkgs-channels";
  rev = "b34ab9683cee9f51dfe2ad97bc5632d2e3683bd4";
  sha256 = "0gryhigjcxv9z1b9jv4hdsl8pk3wcdc8g3ysp258yqfg5qkfnxbf";
}
