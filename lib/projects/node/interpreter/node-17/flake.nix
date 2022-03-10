{
  description = "Node.js interpreter v17";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      defaultPackage = nixpkgs.legacyPackages.${system}.nodejs-17_x;
    });
}
