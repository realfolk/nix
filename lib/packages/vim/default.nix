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
  json = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "json";
    src = pkgs.fetchFromGitHub {
      owner = "elzr";
      repo = "vim-json";
      rev = "3727f089410e23ae113be6222e8a08dd2613ecf2";
      sha256 = "1c19pqrys45pzflj5jyrm4q6hcvs977lv6qsfvbnk7nm4skxrqp1";
    };
    dependencies = [];
  };
  javascript = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "javascript";
    src = pkgs.fetchFromGitHub {
      owner = "pangloss";
      repo = "vim-javascript";
      rev = "d3d8a9772777b4fe27bfad0049f0a8a0399e9882";
      sha256 = "0qmq1ijd6zh8zxab2q4r1qxn1m9szqma50xgc6aa6rfc2ayhdv36";
    };
    dependencies = [];
  };
  vim-rooter = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "vim-rooter";
    src = pkgs.fetchFromGitHub {
      owner = "airblade";
      repo = "vim-rooter";
      rev = "3509dfb80d0076270a04049548738daeedf6dfb9";
      sha256 = "03j26fw0dcvcc81fn8hx1prdwlgnd3g340pbxrzgbgxxq5kr0bwl";
    };
    dependencies = [];
  };
  vim-jsx-typescript = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "vim-jsx-typescript";
    src = pkgs.fetchFromGitHub {
      owner = "peitalin";
      repo = "vim-jsx-typescript";
      rev = "07370d48c605ec027543b52762930165b1b27779";
      sha256 = "190nyy7kr6i3xr6nrjlfv643s1c48kxlbh8ynk8p53yf32gcxwz7";
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
      haskell-vim
      typescript-vim
      vim-rooter
      ledger
      json
      javascript
      vim-jsdoc
      Hoogle
      vim-jsx-typescript
      ale
    ];
    # manually loadable by calling `:packadd $plugin-name`
    opt = with plugins; [
      sensible
      yaml-folds
    ];
  };

  vimrcConfig.customRC = builtins.readFile ./vimrc;
}
