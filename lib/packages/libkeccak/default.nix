{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "libkeccak";
  src = fetchFromGitHub {
    owner = "maandree";
    repo = "libkeccak";
    rev = "a989f8a4f1e812a42335046e790efd819922c2f3";
    hash = "sha256-aGWpzwNSE944wNJsLchJZ4t2m5TNNecN0tUrBK7XtmE=";
  };
  buildPhase = "make";
  installPhase = ''
    PREFIX="$out" make -e install
  '';
}
