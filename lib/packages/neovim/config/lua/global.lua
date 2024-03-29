vim.opt.incsearch = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.hidden = true
vim.opt.updatetime = 300
vim.opt.hlsearch = true
vim.opt.foldenable = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.cmd('colorscheme gruvbox')
vim.g.rooter_patterns = {'.root', '.git', '.git/', 'shell.sh', 'shell.nix'}
vim.g.rooter_silent_chdir = 1
vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')

-- Lualine
require'lualine'.setup({
  options = {
    icons_enabled = false,
    theme = 'gruvbox'
  },
  sections = {
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 2
      },
    },
    lualine_y = {
      {
        'diagnostics',
        sources = {'nvim_diagnostic'}
      }
    }
  }
})

-- Silver-search with grep
vim.cmd([[
  if executable("ag")
    let grepprg = "ag --vimgrep"
  endif
]])

-- Run ctags on save
vim.cmd('autocmd BufWritePost * call system("which ctags &> /dev/null && ctags -R . || exit 0")')
vim.cmd('set wildignore+=*.so,*.swp,*.zip,*.hi,*.o,*/node_modules/*,*/dist/*,*/.dist/*,*/build/*,*/.build/*,*/Godeps/*,*/elm-stuff/*,*/.gem/*,*/.git/*,*/tmp/*')

-- Set up global key bindings.
vim.cmd('let mapleader=","')
local opts = { noremap = true, silent = true }

-- Toggle term
require'toggleterm'.setup({
  open_mapping = [[<leader>tt]],
  hide_numbers = true,
  start_in_insert = true,
  direction = 'float',
  close_on_exit = true,
})

require'gitsigns'.setup({})
local gs = package.loaded.gitsigns

-- Git signs
vim.api.nvim_set_keymap('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>', opts)

-- Misc helpers
vim.api.nvim_set_keymap('n', '<leader>f', ':set filetype=', { noremap = true })                        -- set filetype helper
vim.api.nvim_set_keymap('n', '<leader>h', '<cmd>nohl<CR>', opts)                             -- clear highlighted search items
vim.api.nvim_set_keymap('n', '<leader>n', '<cmd>set invnumber invrelativenumber<CR>', opts)  -- toggle line numbering
vim.api.nvim_set_keymap('n', '<leader><leader>', '<cmd>b#<CR>', opts)                        -- switch to last active buffer
vim.api.nvim_set_keymap('n', '<leader>j', '<cmd>%!jq<CR>', opts)                             -- pretty format JSON
vim.api.nvim_set_keymap('n', '<leader>pc', '<cmd>pclose<CR>', opts)                          -- close preview window

-- Search
vim.api.nvim_set_keymap('', '<C-p>', '<cmd>Telescope find_files<CR>', opts)
vim.api.nvim_set_keymap('', '<C-\\>', '<cmd>Telescope live_grep<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', '<cmd>Telescope buffers<CR>', opts)

-- NERDTree
vim.api.nvim_set_keymap('n', '<leader>to', '<cmd>NERDTreeFocus<CR>', opts)        -- NERDTree focus/open
vim.api.nvim_set_keymap('n', '<leader>tc', '<cmd>NERDTreeClose<CR>', opts)        -- NERDTree close 
vim.api.nvim_set_keymap('n', '<leader>tr', '<cmd>NERDTreeRefreshRoot<CR>', opts)  -- NERDTree refresh 

-- EasyAlign
vim.api.nvim_set_keymap('x', 'ga', '<Plug>EasyAlign', opts)
vim.api.nvim_set_keymap('n', 'ga', '<Plug>EasyAlign', opts)

-- Autoindenting for elm
vim.cmd('autocmd FileType elm setlocal shiftwidth=4 tabstop=4')
