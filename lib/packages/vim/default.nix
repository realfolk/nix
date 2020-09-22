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
};

in

overridden_vim_configurable.customize {

  name = "vim";

  vimrcConfig.packages.myVimPackages = {
    start = with plugins; [
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
      typescript-vim
      vim-rooter
      ledger
      vim-json
      vim-javascript
      vim-jsdoc
      Hoogle
      vim-jsx-typescript
      ale
    ];
    # manually loadable by calling `:packadd $plugin-name`
    opt = with plugins; [
      yaml-folds
    ];
  };

  vimrcConfig.customRC = builtins.readFile ./vimrc;
}
