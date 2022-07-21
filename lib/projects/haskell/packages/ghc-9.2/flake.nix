{
  description = "Haskell packages for GHC 9.2.2";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/d2fc6856824cb87742177eefc8dd534bdb6c3439";
    flakeUtils.url = "github:numtide/flake-utils";

    # 2022-05-08
    haskellLanguageServerSrc = {
      url = "github:haskell/haskell-language-server/9e1738e8c59e2ee5a4a0c17fca2154b936bb7a49";
      flake = false;
    };

    # 2022-03-07
    hieBiosSrc = {
      url = "github:haskell/hie-bios/0d1cdc3ea2a3b87588f24a28bd0da6dc93a952df";
      flake = false;
    };

    # 2022-04-12
    haddockSrc = {
      url = "github:haskell/haddock/0c5447f74bb53f754e7ac32c1a01d57e138a9fc5";
      flake = false;
    };

    # 2022-01-15
    envySrc = {
      url = "github:dmjio/envy/e90e9416da9e45fd2252ae6792896993eccc764d";
      flake = false;
    };

    # 2022-04-27
    haskellFilesystemSrc = {
      url = "github:fpco/haskell-filesystem/064e3baa3168febe30b8db4296abc86b36521b88";
      flake = false;
    };

    # 2019-04-11
    textTrieSrc = {
      url = "github:michaeljklein/text-trie/c698d139c4693d231e081941bc958a8417ffb6c3";
      flake = false;
    };

    # 2014-11-14
    animalcaseSrc = {
      url = "github:ibotty/animalcase/6b8b1adda4f56e854d74c38137d378aaa0636b9d";
      flake = false;
    };

    # 2019-01-24
    relapseSrc = {
      url = "github:iostat/relapse/bd00d20d1b7a3ea2dd60ee6787f2944d850d875d";
      flake = false;
    };

    # 2022-07-20
    # References the "meld/tuple-fix" branch.
    # Fork of airalab/hs-web3 that includes some changes to work
    # with GHC 9.2 and a fix for ABI functions that accept tuples.
    # The fix is in currently-open PR:
    # https://github.com/airalab/hs-web3/pull/131
    hsWeb3Src = {
      #url = "github:airalab/hs-web3/61a35a6187f2d92fdf574fa5765028bd1ac7657e";
      url = "github:QodaFi/hs-web3/901b97e2fecdaac94a7d10b864f3ff70a5bec75a";
      flake = false;
    };

    # 2022-04-06
    ghcExactPrintSrc = {
      url = "github:alanz/ghc-exactprint/d9cb00673552dbc098059100e025592a7389d5a6";
      flake = false;
    };

    # 2022-04-29
    retrieSrc = {
      url = "github:facebookincubator/retrie/6426f3da809c30009c134e357d552f3eb765c1f2";
      flake = false;
    };

    # 2022-04-27
    stylishHaskellSrc = {
      url = "github:haskell/stylish-haskell/v0.14.2.0";
      flake = false;
    };

    # 2022-03-02
    foundationSrc = {
      url = "github:haskell-foundation/foundation/fc4daf9c869f903cec49b37177d1e1633ce01e58";
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
    , ghcExactPrintSrc
    , retrieSrc
    , stylishHaskellSrc
    , foundationSrc
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

      rootHaskellPackages = pkgs.haskell.packages.ghc922;

      packages = rootHaskellPackages.extend (self: super: builtins.mapAttrs (name: value: hlib.dontCheck value) {
        animalcase = hlib.appendPatch (self.callCabal2nix "animalcase" animalcaseSrc { }) ./patches/animalcase.patch;
        apply-refact = self.apply-refact_0_10_0_0;
        basement = self.callCabal2nix "basement" "${foundationSrc}/basement" { };
        envy = hlib.appendPatch (self.callCabal2nix "envy" envySrc { }) ./patches/envy.patch;
        ghc-exactprint = self.callCabal2nix "ghc-exactprint" ghcExactPrintSrc { };
        ghcide = self.callCabal2nix "ghcide" "${haskellLanguageServerSrc}/ghcide" { };
        haddock = self.callCabal2nix "haddock" haddockSrc { };
        haddock-library = hlib.appendPatch (self.callCabal2nix "haddock-library" "${haddockSrc}/haddock-library" { }) ./patches/haddock-library.patch;
        haddock-api = hlib.appendPatch (self.callCabal2nix "haddock-api" "${haddockSrc}/haddock-api" { }) ./patches/haddock-api.patch;
        hspec = self.hspec_2_9_7;
        hspec-core = self.hspec-core_2_9_7;
        hspec-discover = self.hspec-discover_2_9_7;
        hspec-meta = self.hspec-meta_2_9_3;
        relapse = hlib.appendPatch (self.callCabal2nix "relapse" relapseSrc { }) ./patches/relapse.patch;
        retrie = self.callCabal2nix "retrie" retrieSrc { };
        retrie_1_2_0_1 = self.retrie;
        time-compat = hlib.dontCheck super.time-compat;
        text-trie = hlib.appendPatch (self.callCabal2nix "text-trie" textTrieSrc { }) ./patches/text-trie.patch;
        hie-bios = self.callCabal2nix "hie-bios" hieBiosSrc { };
        vinyl = self.vinyl_0_14_3;
        system-fileio = self.callCabal2nix "system-fileio" "${haskellFilesystemSrc}/system-fileio" { };
        # hs-web3 overrides
        jsonrpc-tinyclient = super.callCabal2nix "jsonrpc-tinyclient" "${hsWeb3Src}/packages/jsonrpc" { };
        memory-hexstring = super.callCabal2nix "memory-hexstring" "${hsWeb3Src}/packages/hexstring" { };
        scale = super.callCabal2nix "scale" "${hsWeb3Src}/packages/scale" { };
        web3 = super.callCabal2nix "web3" "${hsWeb3Src}/packages/web3" { };
        web3-bignum = super.callCabal2nix "web3-bignum" "${hsWeb3Src}/packages/bignum" { };
        web3-crypto = super.callCabal2nix "web3-crypto" "${hsWeb3Src}/packages/crypto" { };
        web3-ethereum = super.callCabal2nix "web3-ethereum" "${hsWeb3Src}/packages/ethereum" { };
        web3-ipfs = super.callCabal2nix "web3-ipfs" "${hsWeb3Src}/packages/ipfs" { };
        web3-polkadot = super.callCabal2nix "web3-polkadot" "${hsWeb3Src}/packages/polkadot" { };
        web3-provider = super.callCabal2nix "web3-provider" "${hsWeb3Src}/packages/provider" { };
        web3-solidity = super.callCabal2nix "web3-solidity" "${hsWeb3Src}/packages/solidity" { };
        # haskell-language-server
        haskell-language-server =
          let
            cabalOptions = builtins.concatStringsSep " " [
              "-f-haddockComments"
              "-f-fourmolu"
              "-f-ormolu"
              "-f-floskell"
              "-f-hlint"
              "-fclass"
              "-fcallHierarchy"
              "-feval"
              "-fimportLens"
              "-frefineImports"
              "-frename"
              "-fretrie"
              "-fstylishHaskell"
              "-ftactic"
              "-fmoduleName"
              "-fpragmas"
              "-fsplice"
              "-falternateNumberFormat"
              "-fqualifyImportedNames"
              "-fselectionRange"
              "-fchangeTypeSignature"
            ];
            pkg2 = self.callCabal2nixWithOptions "haskell-language-server" haskellLanguageServerSrc cabalOptions { };
            pkg3 = hlib.dontCheck (hlib.dontHaddock pkg2);
            pkg4 = hlib.enableSharedExecutables (hlib.overrideCabal pkg3
              (_: {
                postInstall = ''
                  remove-references-to -t ${super.shake.data} $out/bin/haskell-language-server
                  remove-references-to -t ${super.js-jquery.data} $out/bin/haskell-language-server
                  remove-references-to -t ${super.js-dgtable.data} $out/bin/haskell-language-server
                  remove-references-to -t ${super.js-flot.data} $out/bin/haskell-language-server
                '';
              }));
          in
          pkg4;
        hls-graph = self.callCabal2nix "hls-graph" "${haskellLanguageServerSrc}/hls-graph" { };
        hls-plugin-api = self.callCabal2nix "hls-plugin-api" "${haskellLanguageServerSrc}/hls-plugin-api" { };
        hls-test-utils = self.callCabal2nix "hls-test-utils" "${haskellLanguageServerSrc}/hls-test-utils" { };
        hls-explicit-imports-plugin = self.callCabal2nix "hls-explicit-imports-plugin" "${haskellLanguageServerSrc}/plugins/hls-explicit-imports-plugin" { };
        hls-refine-imports-plugin = self.callCabal2nix "hls-refine-imports-plugin" "${haskellLanguageServerSrc}/plugins/hls-refine-imports-plugin" { };
        hls-eval-plugin = self.callCabal2nix "hls-eval-plugin" "${haskellLanguageServerSrc}/plugins/hls-eval-plugin" { };
        hls-class-plugin = self.callCabal2nix "hls-class-plugin" "${haskellLanguageServerSrc}/plugins/hls-class-plugin" { };
        hls-call-hierarchy-plugin = self.callCabal2nix "hls-call-hierarchy-plugin" "${haskellLanguageServerSrc}/plugins/hls-call-hierarchy-plugin" { };
        hls-stylish-haskell-plugin = self.callCabal2nix "hls-stylish-haskell-plugin" "${haskellLanguageServerSrc}/plugins/hls-stylish-haskell-plugin" { };
        hls-retrie-plugin = self.callCabal2nix "hls-retrie-plugin" "${haskellLanguageServerSrc}/plugins/hls-retrie-plugin" { };
        hls-tactics-plugin = self.callCabal2nix "hls-tactics-plugin" "${haskellLanguageServerSrc}/plugins/hls-tactics-plugin" { };
        hls-module-name-plugin = self.callCabal2nix "hls-module-name-plugin" "${haskellLanguageServerSrc}/plugins/hls-module-name-plugin" { };
        hls-pragmas-plugin = self.callCabal2nix "hls-pragmas-plugin" "${haskellLanguageServerSrc}/plugins/hls-pragmas-plugin" { };
        hls-splice-plugin = self.callCabal2nix "hls-splice-plugin" "${haskellLanguageServerSrc}/plugins/hls-splice-plugin" { };
        hls-qualify-imported-names-plugin = self.callCabal2nix "hls-qualify-imported-names-plugin" "${haskellLanguageServerSrc}/plugins/hls-qualify-imported-names-plugin" { };
        hls-selection-range-plugin = self.callCabal2nix "hls-selection-range-plugin" "${haskellLanguageServerSrc}/plugins/hls-selection-range-plugin" { };
        hls-alternate-number-format-plugin = self.callCabal2nix "hls-alternate-number-format-plugin" "${haskellLanguageServerSrc}/plugins/hls-alternate-number-format-plugin" { };
        hls-change-type-signature-plugin = self.callCabal2nix "hls-change-type-signature-plugin" "${haskellLanguageServerSrc}/plugins/hls-change-type-signature-plugin" { };
        hls-rename-plugin = self.callCabal2nix "hls-rename-plugin" "${haskellLanguageServerSrc}/plugins/hls-rename-plugin" { };
      });
    in
    { inherit packages; });
}
