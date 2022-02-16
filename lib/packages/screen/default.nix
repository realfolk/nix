{ pkgs }:

let

screenrc = pkgs.writeText "screenrc" (builtins.readFile ./screenrc);

in

pkgs.writeShellScriptBin "screen" ''
  ${pkgs.screen}/bin/screen -c "${screenrc}" $@
''
