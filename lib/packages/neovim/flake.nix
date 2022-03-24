{
  description = "Real Folk's custom neovim.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flakeUtils.url = "github:numtide/flake-utils";

    ### Plugins ###

    # LSP 
    #LEARN
    nvimLspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
    #LEARN
    nvimLspTsUtils = { url = "github:jose-elias-alvarez/nvim-lsp-ts-utils"; flake = false; };
    #LEARN
    nullLs = { url = "github:jose-elias-alvarez/null-ls.nvim"; flake = false; };

    # Syntax highlighting
    vimNix = { url = "github:LnL7/vim-nix"; flake = false; };
    elmVim = { url = "github:lambdatoast/elm.vim"; flake = false; };
    haskellVim = { url = "github:neovimhaskell/haskell-vim"; flake = false; };
    #LEARN
    nvimTreesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };

    # Formatting
    #LEARN
    formatterNvim = { url = "github:mhartington/formatter.nvim"; flake = false; };

    # Themes
    tokyonightNvim = { url = "github:folke/tokyonight.nvim"; flake = false; };
    gruvboxNvim = { url = "github:ellisonleao/gruvbox.nvim"; flake = false; };
    gruvbox = { url = "github:/morhetz/gruvbox"; flake = false; };

    # NERD
    nerdTree = { url = "github:preservim/nerdtree"; flake = false; };
    nerdCommenter = { url = "github:preservim/nerdcommenter"; flake = false; };

    # Completion
    #LEARN
    nvimCmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
    #LEARN
    cmpNvimLsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
    #LEARN
    cmpPath = { url = "github:hrsh7th/cmp-path"; flake = false; };
    #LEARN
    cmpBuffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
    #LEARN
    cmpCmdline = { url = "github:hrsh7th/cmp-cmdline"; flake = false; };
    #LEARN
    luasnip = { url = "github:L3MON4D3/LuaSnip"; flake = false; };

    # Git
    #LEARN
    gitsigns = { url = "github:lewis6991/gitsigns.nvim"; flake = false; };

    # Misc
    #LEARN
    lualineNvim = { url = "github:nvim-lualine/lualine.nvim"; flake = false; };
    vimRooter = { url = "github:airblade/vim-rooter"; flake = false; };
    vimSurround = { url = "github:tpope/vim-surround"; flake = false; };
    fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
    vimSensible = { url = "github:tpope/vim-sensible"; flake = false; };
    #LEARN
    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    #LEARN
    telescopeFzyNative = { url = "github:nvim-telescope/telescope-fzy-native.nvim"; flake = false; };
    #LEARN
    plenary = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    #LEARN
    toggleterm = { url = "github:akinsho/toggleterm.nvim"; flake = false; };
    #LEARN
    vimRzip = { url = "github:lbrayner/vim-rzip"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flakeUtils, ... }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        buildPlugin = name: pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = name;
          version = "master";
          src = builtins.getAttr name inputs;
        };

        plugins = [
          "nvimLspconfig"
          "nvimLspTsUtils"
          "nullLs"
          "vimNix"
          "elmVim"
          "haskellVim"
          "nvimTreesitter"
          "formatterNvim"
          "gruvboxNvim"
          "tokyonightNvim"
          "nerdTree"
          "nerdCommenter"
          "nvimCmp"
          "cmpNvimLsp"
          "cmpPath"
          "cmpBuffer"
          "cmpCmdline"
          "gitsigns"
          "luasnip"
          "lualineNvim"
          "vimRooter"
          "vimSurround"
          "fugitive"
          "vimSensible"
          "telescope"
          "telescopeFzyNative"
          "plenary"
          "toggleterm"
          "vimRzip"
        ];

        neovim = pkgs.wrapNeovim pkgs.neovim-unwrapped {
          vimAlias = true;
          configure = {
            customRC = ''
              luafile ${./config/lua/global.lua}
              luafile ${./config/lua/lsp.lua}
              colorscheme gruvbox
            '';
            packages.myVimPackage = {
              start = map buildPlugin plugins;
            };
          };
        };
      in

      {
        overlay = final: prev: {
          inherit neovim;
        };

        packages = {
          inherit neovim;
        };

        defaultPackage = self.packages.${system}.neovim;
      });
}
