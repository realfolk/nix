{
  description = "Node.js interpreter v17";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flakeUtils, ... }:
    flakeUtils.lib.eachDefaultSystem (system: {
      packages.default = nixpkgs.legacyPackages.${system}.nodejs-17_x;
    });
}
