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
      rev = "9abb310f2b71be869f936c0ed715ae98fc7d703a";
      sha256 = "0fr6zxm3qf3c7b6xx32p890f1gz2i922jz6cfb2cwxb8j5kpby1w";
    };
  };
};

in

overridden_vim_configurable.customize {

  name = "vim";

  vimrcConfig.packages.myVimPackages = {
    start = with plugins; [
      sensible
      gruvbox
      ctrlp
      easy-align
      The_NERD_tree
      The_NERD_Commenter
      surround
      airline
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
    ];
    # manually loadable by calling `:packadd $plugin-name`
    opt = with plugins; [
      yaml-folds
      ale
    ];
  };

  vimrcConfig.customRC = ''
    " NOTE
    " most settings handled by vim-sensible pathogen plugin
    " git://github.com/tpope/vim-sensible.git

		set nocompatible
		syntax enable
    
    " tabs as 2 spaces instead of \t characters
    set tabstop=2 shiftwidth=2 expandtab
    au! BufNewFile,BufRead *.elm set tabstop=4 shiftwidth=4
    au! BufNewFile,BufRead *.py set tabstop=4 shiftwidth=4
    
    " enable line numbers
    set relativenumber
    
    " highlight the active row
    set cursorline

    " some language servers have issues with backup files
    set nobackup
    set nowritebackup

    " always show signcolumn
    set signcolumn=yes

    " hide completion menu short messages
    set shortmess+=c

    " only hide buffers when leaving them
    set hidden

    " improve UX
    set updatetime=300
    
    " highlight all search results
    set incsearch "highlight as i'm searching
    set hlsearch "highlights all results
    
    " set the colorscheme
    colorscheme gruvbox
    set background=dark
    
    " leader shortcuts
    let mapleader=","
    " easier to switch to the last active buffer
    nmap <Leader><Leader> :b#<CR>
    " toggle line numbers
    nmap <Leader>l :set invrelativenumber<CR>
    " open terminal
    nmap <Leader>t :vert terminal
    " unhighlight search results
    nmap <Leader>h :nohlsearch<CR>
    " easily change filestype
    nmap <Leader>f :set filetype=
    " fix js code
    "nmap <Leader>p :ALEFix<CR>
    " pretty JSON
    nmap <Leader>j :%!jq .<CR>
    " close quickfix window
    nmap <Leader>qc :cclose<CR>
    " open quickfix window
    nmap <Leader>qo :copen<CR>

    " remap omnicomplete
    " inoremap <C-n> <C-x><C-o>
    
    " wildignore / ctrlp ignore rules
    set wildignore+=*.so,*.swp,*.zip,*.hi,*.o,*/node_modules/*,*/dist/*,*/build/*,*/Godeps/*,*/elm-stuff/*,*/.gem/*,*/.git/*,*/tmp/*
    
    " NERD tree options
    map <C-l> :NERDTreeToggle<CR>

    " Search tags with CtrlP
    map <C-o> :CtrlPTag<CR>
    
    " easy-align mapping
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)
    
    " set up the_silver_searcher with Ack
    if executable('ag')
      let grepprg = 'ag --vimgrep'
    endif
    
    " auto-syntax rules
    au! BufNewFile,BufRead *.hdl set filetype=txt
    au! BufNewFile,BufRead *.ejs set filetype=html
    au! BufNewFile,BufRead *.ledger set filetype=ledger
    au! BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx

    " run ctags on save, if available
    autocmd BufWritePost * call system('which ctags &> /dev/null && ctags -R . || exit 0')
    
    " rooter config
    let g:rooter_patterns = ['.git', '.git/', 'shell.nix', 'src/']

    " Ale auto-fixing
    let g:ale_linters = {}
    let g:ale_linters['haskell'] = ['hlint', 'ghc']
    let g:ale_linters['typescript'] = ['tslint', 'tsserver']
    let g:ale_fixers = {}
    let g:ale_fixers['javascript'] = ['prettier', 'eslint']
    let g:ale_fixers['typescript'] = ['tslint', 'prettier', 'eslint']
    let g:ale_fixers['haskell'] = ['hlint', 'hfmt']
    let g:ale_javascript_eslint_use_global = 0
    let g:ale_set_loclist = 0
    let g:ale_set_quickfix = 1
    let g:airline#extensions#ale#enabled = 1
    let g:ale_completion_enabled = 1
    set omnifunc=ale#completion#OmniFunc
    " easily jump between errors
    nmap <silent> <C-k> <Plug>(ale_previous_wrap)
    nmap <silent> <C-j> <Plug>(ale_next_wrap)
    nmap <leader>ak <Plug>(ale_previous_wrap)
    nmap <leader>aj <Plug>(ale_next_wrap)
    nmap <leader>ad :ALEDetail<CR>
    nmap <leader>ag :ALEGoToDefinition<CR>
    nmap <leader>agv :ALEGoToDefinitionInVSplit<CR>
    nmap <leader>ar :ALEFindReferences<CR>
    nmap <leader>ah :ALEHover<CR>

    " Set make program repo-specific make script
    if filereadable("./make.sh")
      set makeprg=./make.sh
    elseif filereadable("./scripts/make.sh")
      set makeprg=./scripts/make.sh
    endif

    " Enable per-project .vimrc files
    set exrc
    " Ensure per-project .vimrc files are secure
    set secure

    " Define function to complete various startup tasks
    function StartUp()
      " Load local .vimrc file
      if filereadable("./.vimrc")
        source .vimrc
      endif
      " Start ALE
      packadd ale
    endfunction
    " Load local .vimrc file when starting vim
    autocmd VimEnter * call StartUp()
  '';
}
