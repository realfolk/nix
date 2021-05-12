{ pkgs }:

let

vimConfigurable = pkgs.vim_configurable.override { guiSupport = "false"; };

ledger = pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "ledger";
  src = pkgs.fetchFromGitHub {
    owner = "ledger";
    repo = "vim-ledger";
    rev = "0bce2fd70da351c65d20cb5a1fec20ad3a2ab904";
    sha256 = "0laqvy5pl89fnzc7i2nrrazxhzxhihxqv053vil731lahs16z1d3";
  };
  dependencies = [];
};

yajs-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "yajs-vim";
  src = pkgs.fetchFromGitHub {
    owner = "othree";
    repo = "yajs.vim";
    rev = "2bebc45ce94d02875803c67033b2d294a5375064";
    sha256 = "15ky34nbv0wa9jq92hm7ya4s05zgippkcifd3m8s59n0dy5lkpc0";
  };
};


vim = vimConfigurable.customize {

  name = "vim";

  vimrcConfig.packages.myVimPackages = {
    start = with pkgs.vimPlugins; [
      vim-sensible
      gruvbox
      easy-align
      The_NERD_tree
      The_NERD_Commenter
      surround
      airline
      fugitive
      haskell-vim
      elm-vim
      vim-markdown
      vim-rooter
      ledger
      vim-jsdoc
      yajs-vim #javascript & json syntax highlighting
      yats-vim #typescript syntax highlighting
      Hoogle
      coc-nvim
      fzf-vim
    ];

    # manually loadable by calling `:packadd $plugin-name`
    opt = with pkgs.vimPlugins; [
    ];
  };

  vimrcConfig.customRC = builtins.readFile ./vimrc;
};

vimWrapper = pkgs.writeShellScriptBin "vim" ''
${vim}/bin/vim $@
'';

in

# include: fzf, ag, jq
pkgs.symlinkJoin {
  name = "vim";
  paths = [
    vimWrapper
    pkgs.fzf
    pkgs.ag
    pkgs.jq
  ];
}
