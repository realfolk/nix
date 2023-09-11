{ stdenv, fetchFromGitHub, writeScriptBin, runtimeShell, openssl }:
let
  sha3sum = import ../sha3sum { inherit stdenv fetchFromGitHub; };
in
writeScriptBin "generate-ethereum-account" ''
  #!${runtimeShell}

  OPENSSL_BIN="${openssl}/bin/openssl"
  KECCAK_256SUM_BIN="${sha3sum}/bin/keccak-256sum"

  ${builtins.readFile ./generate-ethereum-account.sh}
''
