{ pkgs }:

let
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

  neovim = pkgs.neovim.override {
    vimAlias = true;
    configure = {
      customRC = ''
        lua << EOF
          ${builtins.readFile ./config/global.lua}
          ${builtins.readFile ./config/language-server.lua}
        EOF
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          vim-sensible
          The_NERD_tree
          The_NERD_Commenter
          gruvbox-community
          surround
          airline
          fugitive
          fzf-vim
          vim-nix
          haskell-vim
          Hoogle
          easy-align
          vim-rooter
          yats-vim
          ledger
          yajs-vim
          nvim-lspconfig
          (nvim-treesitter.withPlugins (
            plugins: with plugins; [
              tree-sitter-nix
              tree-sitter-lua
            ]
          ))
          completion-nvim
          vim-rooter
          vim-stylish-haskell
        ];
        opt = [];
      };
    };
  };

  neovimWrapper = pkgs.writeShellScriptBin "vim" ''
    ${neovim}/bin/nvim $@
  '';

in
  pkgs.symlinkJoin {
    name = "nvim";
    paths = [
      neovimWrapper
      pkgs.fzf
      pkgs.ag
      pkgs.jq
    ];
  }
