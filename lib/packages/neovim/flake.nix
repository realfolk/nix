{
  description = "Real Folk's custom neovim.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    neovim-nightly = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ### Plugins ###

    # LSP 
    #LEARN
    nvim-lspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
    #LEARN
    nvim-lsp-ts-utils = { url = "github:jose-elias-alvarez/nvim-lsp-ts-utils"; flake = false; };
    #LEARN
    null-ls = { url = "github:jose-elias-alvarez/null-ls.nvim"; flake = false; };

    # Syntax highlighting
    vim-nix = { url = "github:LnL7/vim-nix"; flake = false; };
    elm-vim = { url = "github:lambdatoast/elm.vim"; flake = false; };
    haskell-vim = { url = "github:neovimhaskell/haskell-vim"; flake = false; };
    #LEARN
    nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };

    # Formatting
    #LEARN
    formatter-nvim = { url = "github:mhartington/formatter.nvim"; flake = false; };

    # Themes
    tokyonight-nvim = { url = "github:folke/tokyonight.nvim"; flake = false; };
    gruvbox-nvim = { url = "github:ellisonleao/gruvbox.nvim"; flake = false; };
    gruvbox = { url = "github:/morhetz/gruvbox"; flake = false; };

    # NERD
    nerd-tree = { url = "github:preservim/nerdtree"; flake = false; };
    nerd-commenter = { url = "github:preservim/nerdcommenter"; flake = false; };

    # Completion
    #LEARN
    nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
    #LEARN
    cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
    #LEARN
    cmp-path = { url = "github:hrsh7th/cmp-path"; flake = false; };
    #LEARN
    cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
    #LEARN
    cmp-cmdline = { url = "github:hrsh7th/cmp-cmdline"; flake = false; };
    #LEARN
    luasnip = { url = "github:L3MON4D3/LuaSnip"; flake = false; };

    # Git
    #LEARN
    gitsigns = { url = "github:lewis6991/gitsigns.nvim"; flake = false; };

    # Misc
    #LEARN
    lualine-nvim = { url = "github:nvim-lualine/lualine.nvim"; flake = false; };
    vim-rooter = { url = "github:airblade/vim-rooter"; flake = false; };
    vim-surround = { url = "github:tpope/vim-surround"; flake = false; };
    fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
    vim-sensible = { url = "github:tpope/vim-sensible"; flake = false; };
    #LEARN
    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    #LEARN
    telescope-fzy-native = { url = "github:nvim-telescope/telescope-fzy-native.nvim"; flake = false; };
    #LEARN
    plenary = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    #LEARN
    toggleterm = { url = "github:akinsho/toggleterm.nvim"; flake = false; };
    #LEARN
    vim-rzip = { url = "github:lbrayner/vim-rzip"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, neovim-nightly, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        buildPlugin = name: pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = name;
          version = "master";
          src = builtins.getAttr name inputs;
        };

        plugins = [
          "nvim-lspconfig"
          "nvim-lsp-ts-utils"
          "null-ls"
          "vim-nix"
          "elm-vim"
          "haskell-vim"
          "nvim-treesitter"
          "formatter-nvim"
          "gruvbox-nvim"
          "tokyonight-nvim"
          "nerd-tree"
          "nerd-commenter"
          "nvim-cmp"
          "cmp-nvim-lsp"
          "cmp-path"
          "cmp-buffer"
          "cmp-cmdline"
          "gitsigns"
          "luasnip"
          "lualine-nvim"
          "vim-rooter"
          "vim-surround"
          "fugitive"
          "vim-sensible"
          "telescope"
          "telescope-fzy-native"
          "plenary"
          "toggleterm"
          "vim-rzip"
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
