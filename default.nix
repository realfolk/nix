let

systemPkgs = import <nixpkgs> {};

in

rec {

  config = {
    allPkgs = import ./lib/config/package-set.nix { inherit (systemPkgs) fetchFromGitHub; };
  };

  pkgs = {
    vim = lib.importPackage ./lib/packages/vim/default.nix;
    screen = lib.importPackage ./lib/packages/screen/default.nix;
  };

  lib = {

    importPackage = path: import path { pkgs = config.allPkgs; };

    mkShell = { buildInputs ? [], shellHook ? "" }: config.allPkgs.mkShell {
      buildInputs = builtins.concatLists [
        (builtins.attrValues pkgs)
        buildInputs
      ];
      shellHook = ''
        ${shellHook}
        test -f ~/.bashrc && source ~/.bashrc
        #test -f ~/.zshrc && source ~/.zshrc
        #test -f ~/.fishrc && source ~/.fishrc
      '';
    };

  };

}
