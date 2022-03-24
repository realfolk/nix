{
  description = "Real Folk's custom GNU screen.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flakeUtils, ... }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        screenrc = pkgs.writeText "screenrc" (builtins.readFile ./screenrc);

        screen = pkgs.writeShellScriptBin "screen" ''
            ${pkgs.screen}/bin/screen -c "${screenrc}" $@
        '';
      in
      {
        overlays.default = final: prev: {
          inherit screen;
        };

        packages.default = screen;
      });
}
