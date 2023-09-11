{ stdenv, fetchFromGitHub }:
let
  libkeccak = import ../libkeccak { inherit stdenv fetchFromGitHub; };
in
stdenv.mkDerivation {
  name = "sha3sum";
  src = fetchFromGitHub {
    owner = "maandree";
    repo = "sha3sum";
    rev = "07d982d650a3ca3758ae69a78efcfe92249855d2";
    hash = "sha256-z7A7uta4CtxWUELkX+nlxpJuz7xpusBCOhIlwBspHtY=";
  };
  buildInputs = [ libkeccak ];
  buildPhase = "make";
  installPhase = ''
    PREFIX="$out" make -e install
  '';
}
