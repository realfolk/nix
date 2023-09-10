{ fetchFromGitHub }: {
  # LSP

  nvimLspconfig = fetchFromGitHub {
    owner = "neovim";
    repo = "nvim-lspconfig";
    rev = "8dc45a5c142f0b5a5dd34e5cdba33217d5dc6a86";
    hash = "sha256-WM+0HZVy/yOSfaE7BWtiicJDh8rknoIqL4TX+US58Tg=";
  };

  nvimLspTsUtils = fetchFromGitHub {
    owner = "jose-elias-alvarez";
    repo = "nvim-lsp-ts-utils";
    rev = "0a6a16ef292c9b61eac6dad00d52666c7f84b0e7";
    hash = "sha256-38YOgLDtku2BPCaNEmX0555x1QmHuuDSCZL274bBhcg=";
  };

  nullLs = fetchFromGitHub {
    owner = "jose-elias-alvarez";
    repo = "null-ls.nvim";
    rev = "77e53bc3bac34cc273be8ed9eb9ab78bcf67fa48";
    hash = "sha256-WHGIYU65YlbtdQFQVGzdcjrBQmu6aK0jgXEMTyKzdsA=";
  };

  # Syntax highlighting

  vimNix = fetchFromGitHub {
    owner = "LnL7";
    repo = "vim-nix";
    rev = "7d23e97d13c40fcc6d603b291fe9b6e5f92516ee";
    hash = "sha256-W6ExP+iDNo5T8XazxHRpUiECGv+AU5PPoM4CmU7NV+0=";
  };

  elmVim = fetchFromGitHub {
    owner = "lambdatoast";
    repo = "elm.vim";
    rev = "04df290781f8a8a9a800e568262e0f2a077f503e";
    hash = "sha256-F87XgjQU8/fZJSLORPsXQBq9G7kHnaxgBpE4A1Euf/I=";
  };

  haskellVim = fetchFromGitHub {
    owner = "neovimhaskell";
    repo = "haskell-vim";
    rev = "f35d02204b4813d1dbe8b0e98cc39701a4b8e15e";
    hash = "sha256-4FvqwxaMu3Mznrmt4U5NZlmUAdUIiLpr9fW+kjdwcOA=";
  };

  nvimTreesitter = fetchFromGitHub {
    owner = "nvim-treesitter";
    repo = "nvim-treesitter";
    rev = "102f1b2f55575f0a2f18be92eafc0e7142024ad1";
    hash = "sha256-qdlka79CSUWUkHSRNCpxXBnR1dcVu9UzxXutAJ+4LrE=";
  };

  # Formatting

  formatterNvim = fetchFromGitHub {
    owner = "mhartington";
    repo = "formatter.nvim";
    rev = "fa4f2729cc2909db599169f22d8e55632d4c8d59";
    hash = "sha256-c3XEhHB31VKv7vStpTpaIxqHCNM+8I3UyPix89pLZ0M=";
  };

  # Themes

  tokyonightNvim = fetchFromGitHub {
    owner = "folke";
    repo = "tokyonight.nvim";
    rev = "df13e3268a44f142999fa166572fe95a650a0b37";
    hash = "sha256-iSPPwXkTUCtDG5GsQzaFmo+9o/E4XLiGDGLhOeRrN9E=";
  };

  gruvboxNvim = fetchFromGitHub {
    owner = "ellisonleao";
    repo = "gruvbox.nvim";
    rev = "df149bccb19a02c5c2b9fa6ec0716f0c0487feb0";
    hash = "sha256-XTwPcq1dyZKVy1b+FUUjMEHndpcTPYSp1p7bx9m8+Bg=";
  };

  gruvbox = fetchFromGitHub {
    owner = "morhetz";
    repo = "gruvbox";
    rev = "bf2885a95efdad7bd5e4794dd0213917770d79b7";
    hash = "sha256-H8WkOC9NMPXFznv2+dwOj3syNd2sLqszmoMqST/W5hQ=";
  };

  # NERD

  nerdTree = fetchFromGitHub {
    owner = "preservim";
    repo = "nerdtree";
    rev = "fc85a6f07c2cd694be93496ffad75be126240068";
    hash = "sha256-8e+PlvG+x3lPqbhP4YpGtXcO0bPJC4EVJ3t6AjMU4ws=";
  };

  nerdCommenter = fetchFromGitHub {
    owner = "preservim";
    repo = "nerdcommenter";
    rev = "20452116894a6a79f01a1e95d98f02cf085e9bd6";
    hash = "sha256-JxqDTJDHa20mJuaWgMhuZRtwHqTEauRHCL4ogoE+zFc=";
  };

  # Completion

  nvimCmp = fetchFromGitHub {
    owner = "hrsh7th";
    repo = "nvim-cmp";
    rev = "3ac8d6cd29c74ff482d8ea47d45e5081bfc3f5ad";
    hash = "sha256-5/6EFzKYSHxFwonBx5Yk2q7gevIgkAQzmva2KqMfD5o=";
  };

  cmpNvimLsp = fetchFromGitHub {
    owner = "hrsh7th";
    repo = "cmp-nvim-lsp";
    rev = "0e6b2ed705ddcff9738ec4ea838141654f12eeef";
    hash = "sha256-DxpcPTBlvVP88PDoTheLV2fC76EXDqS2UpM5mAfj/D4=";
  };

  cmpPath = fetchFromGitHub {
    owner = "hrsh7th";
    repo = "cmp-path";
    rev = "91ff86cd9c29299a64f968ebb45846c485725f23";
    hash = "sha256-thppiiV3wjIaZnAXmsh7j3DUc6ceSCvGzviwFUnoPaI=";
  };

  cmpBuffer = fetchFromGitHub {
    owner = "hrsh7th";
    repo = "cmp-buffer";
    rev = "3022dbc9166796b644a841a02de8dd1cc1d311fa";
    hash = "sha256-dG4U7MtnXThoa/PD+qFtCt76MQ14V1wX8GMYcvxEnbM=";
  };

  cmpCmdline = fetchFromGitHub {
    owner = "hrsh7th";
    repo = "cmp-cmdline";
    rev = "5af1bb7d722ef8a96658f01d6eb219c4cf746b32";
    hash = "sha256-s3T4fQt9RbtnIhmaeFsFb+8X0fARVke0oITFLVfrtws=";
  };

  luasnip = fetchFromGitHub {
    owner = "L3MON4D3";
    repo = "LuaSnip";
    rev = "b4bc24c4925aeb05fd47d2ee9b24b7f73f5d7e32";
    hash = "sha256-pGPIFHLyDE44ZOWrrCPKDW9fiCbU9T0cFCbZ3r7Ycrk=";
  };

  # Git

  gitsigns = fetchFromGitHub {
    owner = "lewis6991";
    repo = "gitsigns.nvim";
    rev = "814158f6c4b1724c039fcefe79b0be72c9131c2d";
    hash = "sha256-OEtr7SbCGoKcZmDcbw6nUoc8QDxgwexh6M4gGg4CRek=";
  };

  # Misc

  vimAbolish = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-abolish";
    rev = "cb3dcb220262777082f63972298d57ef9e9455ec";
    hash = "sha256-Izzv5wTzIFay7kihhq+SzlCylGn4jE0lQZuNoGqMMXc=";
  };

  lualineNvim = fetchFromGitHub {
    owner = "nvim-lualine";
    repo = "lualine.nvim";
    rev = "05d78e9fd0cdfb4545974a5aa14b1be95a86e9c9";
    hash = "sha256-ltHE8UIquGo07BSlFGM1l3wmTNN43i8kx6QY7Fj2CNo=";
  };

  vimRooter = fetchFromGitHub {
    owner = "airblade";
    repo = "vim-rooter";
    rev = "4f52ca556a0b9e257bf920658714470ea0320b7a";
    hash = "sha256-2kPeDD5oUBWO0DZPALqMiY9D7lqaKBge0MwC1kNZPIs=";
  };

  vimSurround = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-surround";
    rev = "3d188ed2113431cf8dac77be61b842acb64433d9";
    hash = "sha256-DZE5tkmnT+lAvx/RQHaDEgEJXRKsy56KJY919xiH1lE=";
  };

  fugitive = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-fugitive";
    rev = "5f0d280b517cacb16f59316659966c7ca5e2bea2";
    hash = "sha256-hr7ekRKGQU7cvCuCyOv1gSo7HtaTv/F5t783rzNk/WE=";
  };

  vimSensible = fetchFromGitHub {
    owner = "tpope";
    repo = "vim-sensible";
    rev = "3e878abfd6ddc6fb5dba48b41f2b72c3a2f8249f";
    hash = "sha256-wdbUjdR/lGP0v9gblgQXNaokMpUluLZrfujWTy1oXoI=";
  };

  telescope = fetchFromGitHub {
    owner = "nvim-telescope";
    repo = "telescope.nvim";
    rev = "40c31fdde93bcd85aeb3447bb3e2a3208395a868";
    hash = "sha256-he+kggJjzupbmNeje27QV8h6p74IpgJreokKb9sMNAw=";
  };

  telescopeFzyNative = fetchFromGitHub {
    owner = "nvim-telescope";
    repo = "telescope-fzy-native.nvim";
    rev = "282f069504515eec762ab6d6c89903377252bf5b";
    hash = "sha256-ntSc/Z2KGwAPwBSgQ2m+Q9HgpGUwGbd+4fA/dtzOXY4=";
  };

  plenary = fetchFromGitHub {
    owner = "nvim-lua";
    repo = "plenary.nvim";
    rev = "9ac3e9541bbabd9d73663d757e4fe48a675bb054";
    hash = "sha256-tG+BrCgE1L7QMbchSzjLfQfpI09uTQXbx7OeFuVEcDQ=";
  };

  toggleterm = fetchFromGitHub {
    owner = "akinsho";
    repo = "toggleterm.nvim";
    rev = "68fdf851c2b7901a7065ff129b77d3483419ddce";
    hash = "sha256-G5W1XN5mXnrx3TR8/0H8nHmO6o38z9i+ZkrTz22HlxI=";
  };

  vimRzip = fetchFromGitHub {
    owner = "lbrayner";
    repo = "vim-rzip";
    rev = "f65400fed27b27c7cff7ef8d428c4e5ff749bf28";
    hash = "sha256-xy7rNqDVqlGapKClrP5BhfOORlMzHOQ8oIc8FdZT/AE=";
  };
}
