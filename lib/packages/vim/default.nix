{ pkgs }:

let

overridden_vim_configurable = pkgs.vim_configurable.override { guiSupport = "false"; };

plugins = pkgs.vimPlugins // {
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
  yaml-folds = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "yaml-folds";
    src = pkgs.fetchFromGitHub {
      owner = "pedrohdz";
      repo = "vim-yaml-folds";
      rev = "cdf11e6876585d5cc342c339088621bd08b16404";
      sha256 = "0yp2jgaqiria79lh75fkrs77rw7nk518bq63w9bvyy814i7s4scn";
    };
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
};

in

overridden_vim_configurable.customize {

  name = "vim";

  vimrcConfig.packages.myVimPackages = {
    start = with plugins; [
      vim-sensible
      gruvbox
      ctrlp
      easy-align
      The_NERD_tree
      The_NERD_Commenter
      surround
      airline
      fugitive
      haskell-vim
      vim-markdown
      elm-vim
      vim-rooter
      ledger
      vim-jsdoc
      yajs-vim #javascript & json syntax highlighting
      yats-vim #typescript syntax highlighting
      Hoogle
      ale
    ];
    # manually loadable by calling `:packadd $plugin-name`
    opt = with plugins; [
      yaml-folds
    ];
  };

  vimrcConfig.customRC = builtins.readFile ./vimrc;
}
