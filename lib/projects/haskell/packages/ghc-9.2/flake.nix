{
  description = "Haskell packages for GHC 9.2.6";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flakeUtils.url = "github:numtide/flake-utils";

    haskellLanguageServerSrc = {
      url = "github:haskell/haskell-language-server/1.9.0.0";
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
      url = "github:QodaFi/hs-web3/7cf7dbf7acee214845347b30354448b0ac2a632e";
      flake = false;
    };

    # 2022-04-06
    ghcExactPrintSrc = {
      url = "github:alanz/ghc-exactprint/d9cb00673552dbc098059100e025592a7389d5a6";
      flake = false;
    };

    # 2022-04-27
    stylishHaskellSrc = {
      url = "github:haskell/stylish-haskell/v0.14.2.0";
      flake = false;
    };

  };

  outputs =
    { self
    , nixpkgs
    , flakeUtils
    , haskellLanguageServerSrc
    , haddockSrc
    , envySrc
    , haskellFilesystemSrc
    , textTrieSrc
    , animalcaseSrc
    , relapseSrc
    , hsWeb3Src
    , ghcExactPrintSrc
    , stylishHaskellSrc
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

      rootHaskellPackages = pkgs.haskell.packages.ghc926;

      packages = rootHaskellPackages.extend (self: super: builtins.mapAttrs (name: value: hlib.dontCheck value) {
        animalcase = hlib.appendPatch (self.callCabal2nix "animalcase" animalcaseSrc { }) ./patches/animalcase.patch;
        apply-refact = self.apply-refact_0_10_0_0;
        envy = hlib.appendPatch (self.callCabal2nix "envy" envySrc { }) ./patches/envy.patch;
        ghc-exactprint = self.callCabal2nix "ghc-exactprint" ghcExactPrintSrc { };
        haddock = self.callCabal2nix "haddock" haddockSrc { };
        haddock-library = hlib.appendPatch (self.callCabal2nix "haddock-library" "${haddockSrc}/haddock-library" { }) ./patches/haddock-library.patch;
        haddock-api = hlib.appendPatch (self.callCabal2nix "haddock-api" "${haddockSrc}/haddock-api" { }) ./patches/haddock-api.patch;
        relapse = hlib.appendPatch (self.callCabal2nix "relapse" relapseSrc { }) ./patches/relapse.patch;
        time-compat = hlib.dontCheck super.time-compat;
        text-trie = hlib.appendPatch (self.callCabal2nix "text-trie" textTrieSrc { }) ./patches/text-trie.patch;
        system-fileio = self.callCabal2nix "system-fileio" "${haskellFilesystemSrc}/system-fileio" { };
        # hs-web3 overrides
        jsonrpc-tinyclient = self.callCabal2nix "jsonrpc-tinyclient" "${hsWeb3Src}/packages/jsonrpc" { };
        memory-hexstring = self.callCabal2nix "memory-hexstring" "${hsWeb3Src}/packages/hexstring" { };
        scale = self.callCabal2nix "scale" "${hsWeb3Src}/packages/scale" { };
        web3 = self.callCabal2nix "web3" "${hsWeb3Src}/packages/web3" { };
        web3-bignum = self.callCabal2nix "web3-bignum" "${hsWeb3Src}/packages/bignum" { };
        web3-crypto = self.callCabal2nix "web3-crypto" "${hsWeb3Src}/packages/crypto" { };
        web3-ethereum = self.callCabal2nix "web3-ethereum" "${hsWeb3Src}/packages/ethereum" { };
        web3-ipfs = self.callCabal2nix "web3-ipfs" "${hsWeb3Src}/packages/ipfs" { };
        web3-polkadot = self.callCabal2nix "web3-polkadot" "${hsWeb3Src}/packages/polkadot" { };
        web3-provider = self.callCabal2nix "web3-provider" "${hsWeb3Src}/packages/provider" { };
        web3-solidity = self.callCabal2nix "web3-solidity" "${hsWeb3Src}/packages/solidity" { };
        haskell-language-server =
          let
            cabalOptions = builtins.concatStringsSep " " [
              "-f-fourmolu"
              "-f-ormolu"
              "-f-floskell"
            ];
            pkg2 = self.callCabal2nixWithOptions "haskell-language-server" haskellLanguageServerSrc cabalOptions { };
            pkg3 = hlib.dontCheck (hlib.dontHaddock pkg2);
            pkg4 = hlib.enableSharedExecutables pkg3;
          in
          pkg4;
        hls-gadt-plugin = hlib.dontHaddock super.hls-gadt-plugin;
        hls-rename-plugin = hlib.dontHaddock super.hls-rename-plugin;
        hls-call-hierarchy-plugin = self.callCabal2nix "hls-call-hierarchy-plugin" "${haskellLanguageServerSrc}/plugins/hls-call-hierarchy-plugin" { };
      });
    in
    { inherit packages; });
}
