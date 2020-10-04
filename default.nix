rec {

  config = {
    pkgSet = import ./lib/config/package-set.nix;
  };

  pkgs = {
    vim = lib.importPackage ./lib/packages/vim/default.nix;
    screen = lib.importPackage ./lib/packages/screen/default.nix;
  };

  lib = {

    projects = args: ((import ./lib/projects/default.nix) args) // {
      haskell = import ./lib/projects/haskell/default.nix;
      static = import ./lib/projects/static/default.nix;
    };

    importPackage = path: import path { pkgs = config.pkgSet; };

    mkShell = { buildInputs ? [], shellHook ? "" }: config.pkgSet.mkShell {
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
