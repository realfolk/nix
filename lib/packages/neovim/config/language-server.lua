-- Executed when language server has been attached.
local opts = { noremap = true, silent = true }
local on_attach = function(client, bufnr)

  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Customize diagnostic handling.
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        underline = true,
        update_in_insert = false
      }
    )

  -- Customize the LSP diagnostic gutter signs
  local signs = { Error = ">>", Warning = ">", Hint = "*", Information = ">" }
  for type, icon in pairs(signs) do
    local name = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  end
  vim.cmd('highlight! link LspDiagnosticsSignError GruvboxRed')
  vim.cmd('highlight! link LspDiagnosticsSignWarning GruvboxYellow')
  vim.cmd('highlight! link LspDiagnosticsSignHint GruvboxGreen')
  vim.cmd('highlight! link LspDiagnosticsSignInformation GruvboxGray')

  vim.cmd('highlight! link LspDiagnosticsUnderlineError GruvboxRed')
  vim.cmd('highlight! link LspDiagnosticsUnderlineWarning GruvboxYellow')
  vim.cmd('highlight! link LspDiagnosticsUnderlineHint GruvboxGreen')
  vim.cmd('highlight! link LspDiagnosticsUnderlineInformation GruvboxGray')

  -- Set up auto-complete (nvim-compe)
  vim.o.completeopt = "menuone,noselect"
  require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    resolve_timeout = 800;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = {
      border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
      winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
      max_width = 120,
      min_width = 60,
      max_height = math.floor(vim.o.lines * 0.3),
      min_height = 1,
    };
    source = {
      path = true;
      buffer = true;
      calc = true;
      nvim_lsp = true;
      nvim_lua = true;
      vsnip = true;
      ultisnips = true;
      luasnip = true;
    };
  }

  -- Format on save.
  vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

  -- Set up language server keybindings.
  -- Goto definition/declaration
  buf_set_keymap('n', '<leader>ag', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leader>aG', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)

  -- Hover
  buf_set_keymap('n', '<leader>ah', '<cmd>lua vim.lsp.buf.hover({focusable=false})<CR>', opts)

  -- Rename
  buf_set_keymap('n', '<leader>an', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

  -- Diagnostics
  buf_set_keymap('n', '<C-j>', '<cmd>lua vim.lsp.diagnostic.goto_next({enable_popup=false})<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.diagnostic.goto_prev({enable_popup=false})<CR>', opts)
  buf_set_keymap('n', '<leader>ak', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})<CR>', opts)

  -- Diagnostics in preview window
  buf_set_keymap('n', '<leader>ad', '<cmd>lua PrintDiagnostics()<CR>', opts)

  -- Location list
  buf_set_keymap('n', '<leader>lo', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<leader>lc', '<cmd>lclose<CR>', opts)
  buf_set_keymap('n', '<leader>lp', '<cmd>lprevious<CR>', opts)
  buf_set_keymap('n', '<leader>ln', '<cmd>lnext<CR>', opts)

  -- Quickfix window
  buf_set_keymap('n', '<leader>qo', '<cmd>copen<CR>', opts)
  buf_set_keymap('n', '<leader>qc', '<cmd>cclose<CR>', opts)
  buf_set_keymap('n', '<leader>qp', '<cmd>cprevious<CR>', opts)
  buf_set_keymap('n', '<leader>qn', '<cmd>cnext<CR>', opts)

  -- Format
  buf_set_keymap('n', '<leader>af', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end


-- Print the diagnostics under the cursor to the Preview Window
function PrintDiagnostics(opts, bufnr, line_nr, client_id)
  opts = opts or {}
  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(bufnr)[1] - 1)

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts, client_id)
  if vim.tbl_isempty(line_diagnostics) then return end

  local lines = {}
  for i, diagnostic in ipairs(line_diagnostics) do
    local str = diagnostic.message
    for s in str:gmatch("[^\r\n]+") do
      table.insert(lines, s)
    end
  end
  ShowInPreview(lines)
end

-- Opens the Preview Window and displays the given diagnostic table.
function ShowInPreview(lines)
  vim.cmd([[
    pclose
    keepalt new +setlocal\ previewwindow|setlocal\ buftype=nofile|setlocal\ noswapfile|setlocal\ wrap [Document]
    setl bufhidden=wipe
    setl nobuflisted
    setl nospell
    exe 'setl filetype=text'
    setl conceallevel=0
    setl nofoldenable
  ]])
  vim.api.nvim_buf_set_lines(0, 0, -1, 0, lines)
  vim.cmd('exe "normal! z" .' .. #lines .. '. "\\<cr>"')
  vim.cmd([[
    exe "normal! gg"
    wincmd p
  ]])
end


-- Load language servers and override on_attach.
local nvim_lsp = require('lspconfig')
nvim_lsp.elmls.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150
  }
}

nvim_lsp.hls.setup {
  flags = {
    debounce_text_changes = 150
  },
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false -- We let stylish-haskell plugin handle formatting.
    on_attach(client)
  end
}

