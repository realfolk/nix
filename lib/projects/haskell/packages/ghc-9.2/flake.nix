# NOTE: If I run `nix flake show path:./lib/projects/haskell/packages/ghc-9.2 --verbose` on this flake I get the following error:
#
# > evaluating 'packages.x86_64-linux.Cabal'...
# > error: expected a derivation
#
# TODO: Figure out what's happening and how to fix it.

{
  description = "Haskell packages for GHC 9.2.6";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=23.05";
    flakeUtils.url = "github:numtide/flake-utils";

    # 2022-04-12
    haddockSrc = {
      url = "github:haskell/haddock/0c5447f74bb53f754e7ac32c1a01d57e138a9fc5";
      flake = false;
    };

    # 2019-04-11
    textTrieSrc = {
      url = "github:realfolk/text-trie/fab16265b5c17e158820ed0356cd88eb4d34c2ed";
      flake = false;
    };

    # 2014-11-14
    animalcaseSrc = {
      url = "github:ibotty/animalcase/6b8b1adda4f56e854d74c38137d378aaa0636b9d";
      flake = false;
    };

    # 2023-06-09
    # References the QodaFi/hs-web3 "master" branch.
    # Fork of airalab/hs-web3 that includes some changes to work
    # with GHC 9.2 via Nix.
    hsWeb3Src = {
      url = "github:QodaFi/hs-web3/455e28c7189b21c427d7960e37b685ad802dd2f0";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flakeUtils
    , haddockSrc
    , textTrieSrc
    , animalcaseSrc
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

      rootHaskellPackages = pkgs.haskell.packages.ghc926;

      packages = rootHaskellPackages.extend (self: super: builtins.mapAttrs (name: value: hlib.dontCheck value) {
        animalcase = hlib.appendPatch (self.callCabal2nix "animalcase" animalcaseSrc { }) ./patches/animalcase.patch;
        haddock = self.callCabal2nix "haddock" haddockSrc { };
        haddock-library = hlib.appendPatch (self.callCabal2nix "haddock-library" "${haddockSrc}/haddock-library" { }) ./patches/haddock-library.patch;
        haddock-api = hlib.appendPatch (self.callCabal2nix "haddock-api" "${haddockSrc}/haddock-api" { }) ./patches/haddock-api.patch;
        text-trie = self.callCabal2nix "text-trie" textTrieSrc { };
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
        # haskell-language-server overrides
        haskell-language-server = hlib.dontHaddock super.haskell-language-server;
        hls-alternate-number-format-plugin = hlib.dontHaddock super.hls-alternate-number-format-plugin;
        hls-cabal-fmt-plugin = hlib.dontHaddock super.hls-cabal-fmt-plugin;
        hls-cabal-plugin = hlib.dontHaddock super.hls-cabal-plugin;
        hls-call-hierarchy-plugin = hlib.dontHaddock super.hls-call-hierarchy-plugin;
        hls-change-type-signature-plugin = hlib.dontHaddock super.hls-change-type-signature-plugin;
        hls-class-plugin = hlib.dontHaddock super.hls-class-plugin;
        hls-code-range-plugin = hlib.dontHaddock super.hls-code-range-plugin;
        hls-eval-plugin = hlib.dontHaddock super.hls-eval-plugin;
        hls-explicit-fixity-plugin = hlib.dontHaddock super.hls-explicit-fixity-plugin;
        hls-explicit-imports-plugin = hlib.dontHaddock super.hls-explicit-imports-plugin;
        hls-explicit-record-fields-plugin = hlib.dontHaddock super.hls-explicit-record-fields-plugin;
        hls-floskell-plugin = hlib.dontHaddock super.hls-floskell-plugin;
        hls-fourmolu-plugin = hlib.dontHaddock super.hls-fourmolu-plugin;
        hls-gadt-plugin = hlib.dontHaddock super.hls-gadt-plugin;
        hls-graph = hlib.dontHaddock super.hls-graph;
        hls-hlint-plugin = hlib.dontHaddock super.hls-hlint-plugin;
        hls-module-name-plugin = hlib.dontHaddock super.hls-module-name-plugin;
        hls-ormolu-plugin = hlib.dontHaddock super.hls-ormolu-plugin;
        hls-plugin-api = hlib.dontHaddock super.hls-plugin-api;
        hls-pragmas-plugin = hlib.dontHaddock super.hls-pragmas-plugin;
        hls-qualify-imported-names-plugin = hlib.dontHaddock super.hls-qualify-imported-names-plugin;
        hls-refactor-plugin = hlib.dontHaddock super.hls-refactor-plugin;
        hls-refine-imports-plugin = hlib.dontHaddock super.hls-refine-imports-plugin;
        hls-rename-plugin = hlib.dontHaddock super.hls-rename-plugin;
        hls-retrie-plugin = hlib.dontHaddock super.hls-retrie-plugin;
        hls-splice-plugin = hlib.dontHaddock super.hls-splice-plugin;
        hls-stylish-haskell-plugin = hlib.dontHaddock super.hls-stylish-haskell-plugin;
        hls-test-utils = hlib.dontHaddock super.hls-test-utils;
      });
    in
    { inherit packages; });
}
