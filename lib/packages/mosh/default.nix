{
  lib, stdenv, fetchFromGitHub,
  autoreconfHook, pkg-config, makeWrapper,
  protobuf, ncurses, zlib, openssl, bash-completion,
  perlPackages, libutempter, glibcLocales
}:
stdenv.mkDerivation {
  pname = "mosh";
  version = "1.3.2";
  src = fetchFromGitHub {
    owner = "mobile-shell";
    repo = "mosh";
    rev = "c16108f0171b89fab98666be74a3298ed8aa2ced";
    hash = "sha256-Wj0l4eZKbE8NJ5zi2TWhnC9r5m/vTBXohFLFk0eaf+4=";
  };
  nativeBuildInputs = [ autoreconfHook pkg-config makeWrapper ];
  buildInputs = [
    protobuf
    ncurses
    zlib
    openssl
    bash-completion
  ]
  ++ (with perlPackages; [ perl IOTty ])
  ++ lib.optional stdenv.isLinux libutempter;

  configurePhase = ''
    ./autogen.sh;
    ./configure;
  '';

  installPhase = ''
    make prefix=$out install;
    wrapProgram $out/bin/mosh --prefix PERL5LIB : $PERL5LIB;
  ''
  + lib.strings.optionalString (glibcLocales != null)
    "wrapProgram $out/bin/mosh-server --set LOCALE_ARCHIVE ${glibcLocales}/lib/locale/locale-archive;";
}
