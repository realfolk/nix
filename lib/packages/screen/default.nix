{ writeText, writeShellScriptBin, screen }:
let
  screenrc = writeText "screenrc" (builtins.readFile ./screenrc);
in
writeShellScriptBin "screen" ''
  ${screen}/bin/screen -c "${screenrc}" $@
''
