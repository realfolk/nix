{
  description = "Real Folk's custom tmux.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=22.11";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flakeUtils, ... }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        config = pkgs.writeText "tmux.conf" (builtins.readFile ./tmux.conf);

        tmux = pkgs.writeShellScriptBin "tmux" ''
          ${pkgs.tmux}/bin/tmux -f "${config}" $@
        '';

        tmux-nix-shell-command = pkgs.writeShellScriptBin "tmux-nix-shell-command" ''
          if test -x shell.sh
          then
            echo -n ./shell.sh
          elif test -f ./flake.nix && test -z "$IN_NIX_SHELL"
          then
            echo -n nix develop path:./
          else
            echo -n "$SHELL"
          fi
        '';

        tmux-new = pkgs.writeShellScriptBin "tmux-new" ''
          test -z "$1" && echo "Please enter a name for your session." && exit 1
          ${tmux}/bin/tmux new-session -n shell -s "$1" $(${tmux-nix-shell-command}/bin/tmux-nix-shell-command)
        '';

        tmux-attach = pkgs.writeShellScriptBin "tmux-attach" ''
          test -z "$1" && echo "Please enter a name for the session to reattach." && exit 1
          ${tmux}/bin/tmux attach-session -t "$1"
        '';

        bundled-tmux = pkgs.symlinkJoin {
          name = "bundled-tmux";
          paths = [ tmux tmux-nix-shell-command tmux-new tmux-attach ];
        };
      in
      {
        overlays.default = final: prev: {
          tmux = bundled-tmux;
        };

        packages.default = bundled-tmux;
      });
}
