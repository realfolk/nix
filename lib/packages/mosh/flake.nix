{
  description = "Builds mosh from source (latest). Used to enable truecolor.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mosh-src = { url = "github:mobile-shell/mosh?ref=master"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, mosh-src, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        mosh = with pkgs; stdenv.mkDerivation {
          pname = "mosh";
          version = "1.3.2";
          src = mosh-src;
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
        };
      in
      {
        overlay = final: prev: {
          inherit mosh;
        };

        packages = {
          inherit mosh;
        };

        defaultPackage = self.packages.${system}.mosh;
      });
}
