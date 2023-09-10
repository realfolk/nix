{ writeText, writeShellScriptBin, symlinkJoin, tmux }:
let
  config = writeText "tmux.conf" (builtins.readFile ./tmux.conf);

  tmux-with-config = writeShellScriptBin "tmux" ''
    ${tmux}/bin/tmux -f "${config}" $@
  '';

  tmux-nix-shell-command = writeShellScriptBin "tmux-nix-shell-command" ''
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

  tmux-new = writeShellScriptBin "tmux-new" ''
    test -z "$1" && echo "Please enter a name for your session." && exit 1
    ${tmux-with-config}/bin/tmux new-session -n shell -s "$1" $(${tmux-nix-shell-command}/bin/tmux-nix-shell-command)
  '';

  tmux-attach = writeShellScriptBin "tmux-attach" ''
    test -z "$1" && echo "Please enter a name for the session to reattach." && exit 1
    ${tmux-with-config}/bin/tmux attach-session -t "$1"
  '';
in
symlinkJoin {
  name = "bundled-tmux";
  paths = [ tmux-with-config tmux-nix-shell-command tmux-new tmux-attach ];
}
