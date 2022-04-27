{
  description = "Haskell packages for GHC 9.2.1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/30d3d79b7d3607d56546dd2a6b49e156ba0ec634";
    flakeUtils.url = "github:numtide/flake-utils";

    haskellLanguageServerSrc = {
      url = "github:haskell/haskell-language-server/a538641bf76ead5bc24f19926d259b67e4aa9c01";
      flake = false;
    };

    hieBiosSrc = {
      url = "github:haskell/hie-bios/0d1cdc3ea2a3b87588f24a28bd0da6dc93a952df";
      flake = false;
    };

    haddockSrc = {
      url = "github:haskell/haddock/ghc-9.2";
      flake = false;
    };

    envySrc = {
      url = "github:dmjio/envy/e90e9416da9e45fd2252ae6792896993eccc764d";
      flake = false;
    };

    haskellFilesystemSrc = {
      url = "github:fpco/haskell-filesystem/93b5f5dda080edf2912fb484518753d9dbca56cc";
      flake = false;
    };

    textTrieSrc = {
      url = "github:michaeljklein/text-trie/c698d139c4693d231e081941bc958a8417ffb6c3";
      flake = false;
    };

    animalcaseSrc = {
      url = "github:ibotty/animalcase/6b8b1adda4f56e854d74c38137d378aaa0636b9d";
      flake = false;
    };

    relapseSrc = {
      url = "github:iostat/relapse/bd00d20d1b7a3ea2dd60ee6787f2944d850d875d";
      flake = false;
    };

    hsWeb3Src = {
      url = "github:airalab/hs-web3/078bcd35b11e585ad93aa82b5a98fbfa5d02ac52";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flakeUtils
    , haskellLanguageServerSrc
    , hieBiosSrc
    , haddockSrc
    , envySrc
    , haskellFilesystemSrc
    , textTrieSrc
    , animalcaseSrc
    , relapseSrc
    , hsWeb3Src
    , ...
    }:
    flakeUtils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        # Many haskell dependencies are usually marked as broken.
        config.allowBroken = true;
      };

      hlib = pkgs.haskell.lib;

      rootHaskellPackages = pkgs.haskell.packages.ghc921;

      packages = rootHaskellPackages.extend (self: super: builtins.mapAttrs (name: value: hlib.dontCheck value) {
        animalcase = hlib.appendPatch (self.callCabal2nix "animalcase" animalcaseSrc { }) ./patches/animalcase.patch;
        haddock = self.callCabal2nix "haddock" haddockSrc { };
        haddock-library = hlib.appendPatch (self.callCabal2nix "haddock-library" "${haddockSrc}/haddock-library" { }) ./patches/haddock-library.patch;
        haddock-api = hlib.appendPatch
          (self.callCabal2nix "haddock-api" "${haddockSrc}/haddock-api" {
            hspec = self.hspec_2_9_4;
          }) ./patches/haddock-api.patch;
        envy = hlib.appendPatch (self.callCabal2nix "envy" envySrc { }) ./patches/envy.patch;
        hspec-core_2_9_4 = super.hspec-core_2_9_4.override {
          hspec-meta = self.hspec-meta_2_9_3;
        };
        hspec-discover_2_9_4 = super.hspec-discover_2_9_4.override {
          hspec-meta = self.hspec-meta_2_9_3;
        };
        hspec_2_9_4 = super.hspec_2_9_4.override {
          hspec-core = self.hspec-core_2_9_4;
          hspec-discover = self.hspec-discover_2_9_4;
        };
        ghcide = self.callCabal2nix "ghcide" "${haskellLanguageServerSrc}/ghcide" { };
        relapse = hlib.appendPatch (self.callCabal2nix "relapse" relapseSrc { }) ./patches/relapse.patch;
        scale = hlib.appendPatch (self.callCabal2nix "scale" "${hsWeb3Src}/packages/scale" { }) ./patches/scale.patch;
        web3 = hlib.appendPatch (self.callCabal2nix "web3" "${hsWeb3Src}/packages/web3" { }) ./patches/web3.patch;
        memory-hexstring = hlib.appendPatch (self.callCabal2nix "memory-hexstring" "${hsWeb3Src}/packages/hexstring" { }) ./patches/memory-hexstring.patch;
        jsonrpc-tinyclient = hlib.appendPatch (self.callCabal2nix "jsonrpc-tinyclient" "${hsWeb3Src}/packages/jsonrpc" { }) ./patches/jsonrpc-tinyclient.patch;
        web3-provider = hlib.appendPatch (self.callCabal2nix "web3-provider" "${hsWeb3Src}/packages/provider" { }) ./patches/web3-provider.patch;
        web3-crypto = hlib.appendPatch (self.callCabal2nix "web3-crypto" "${hsWeb3Src}/packages/crypto" { }) ./patches/web3-crypto.patch;
        web3-solidity = hlib.appendPatch (self.callCabal2nix "web3-solidity" "${hsWeb3Src}/packages/solidity" { }) ./patches/web3-solidity.patch;
        web3-ethereum = hlib.appendPatch (self.callCabal2nix "web3-ethereum" "${hsWeb3Src}/packages/ethereum" { }) ./patches/web3-ethereum.patch;
        web3-bignum = hlib.appendPatch (self.callCabal2nix "web3-bignum" "${hsWeb3Src}/packages/bignum" { }) ./patches/web3-bignum.patch;
        web3-polkadot = hlib.appendPatch (self.callCabal2nix "web3-polkadot" "${hsWeb3Src}/packages/polkadot" { }) ./patches/web3-polkadot.patch;
        system-fileio = hlib.appendPatch (self.callCabal2nix "system-fileio" "${haskellFilesystemSrc}/system-fileio" { }) ./patches/system-fileio.patch;
        text-trie = hlib.appendPatch (self.callCabal2nix "text-trie" textTrieSrc { }) ./patches/text-trie.patch;
        hie-bios = self.callCabal2nix "hie-bios" hieBiosSrc { };
        vinyl = self.vinyl_0_14_1;
        haskell-language-server =
          let
            pkg0 = self.callCabal2nix "haskell-language-server" haskellLanguageServerSrc { };
            pkg1 = pkgs.lib.foldr (flag: pkg: hlib.disableCabalFlag pkg flag) pkg0 [
              "haddockComments"
            ];
            pkg2 = hlib.dontCheck (hlib.dontHaddock pkg1);
            pkg3 = hlib.enableSharedExecutables (hlib.overrideCabal pkg2
              (_: {
                postInstall = ''
                  remove-references-to -t ${super.shake.data} $out/bin/haskell-language-server
                  remove-references-to -t ${super.js-jquery.data} $out/bin/haskell-language-server
                  remove-references-to -t ${super.js-dgtable.data} $out/bin/haskell-language-server
                  remove-references-to -t ${super.js-flot.data} $out/bin/haskell-language-server
                '';
              }));
          in
          pkg3.override {
            hls-haddock-comments-plugin = null;
          };
        hls-graph = self.callCabal2nix "hls-graph" "${haskellLanguageServerSrc}/hls-graph" { };
        hls-plugin-api = self.callCabal2nix "hls-plugin-api" "${haskellLanguageServerSrc}/hls-plugin-api" { };
        hls-test-utils = self.callCabal2nix "hls-test-utils" "${haskellLanguageServerSrc}/hls-test-utils" { };
        hls-explicit-imports-plugin = self.callCabal2nix "hls-explicit-imports-plugin" "${haskellLanguageServerSrc}/plugins/hls-explicit-imports-plugin" { };
        hls-refine-imports-plugin = self.callCabal2nix "hls-refine-imports-plugin" "${haskellLanguageServerSrc}/plugins/hls-refine-imports-plugin" { };
        hls-eval-plugin = self.callCabal2nix "hls-eval-plugin" "${haskellLanguageServerSrc}/plugins/hls-eval-plugin" { };
        hls-alternate-number-format-plugin = self.callCabal2nix "hls-alternate-number-format-plugin" "${haskellLanguageServerSrc}/plugins/hls-alternate-number-format-plugin" { };
        hls-change-type-signature-plugin = self.callCabal2nix "hls-change-type-signature-plugin" "${haskellLanguageServerSrc}/plugins/hls-change-type-signature-plugin" { };
        hls-floskell-plugin = self.callCabal2nix "hls-floskell-plugin" "${haskellLanguageServerSrc}/plugins/hls-floskell-plugin" { };
        hls-fourmolu-plugin = self.callCabal2nix "hls-fourmolu-plugin" "${haskellLanguageServerSrc}/plugins/hls-fourmolu-plugin" { };
        hls-ormolu-plugin = self.callCabal2nix "hls-ormolu-plugin" "${haskellLanguageServerSrc}/plugins/hls-ormolu-plugin" { };
      });
    in
    { inherit packages; });
}
