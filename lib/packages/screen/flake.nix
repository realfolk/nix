{
  description = "Real Folk's custom GNU screen.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        screenrc = pkgs.writeText "screenrc" (builtins.readFile ./screenrc);

        screen = pkgs.writeShellScriptBin "screen" ''
            ${pkgs.screen}/bin/screen -c "${screenrc}" $@
        '';
      in
      {
        overlay = final: prev: {
          inherit screen;
        };

        packages = {
          inherit screen;
        };

        defaultPackage = self.packages.${system}.screen;
      });
}
