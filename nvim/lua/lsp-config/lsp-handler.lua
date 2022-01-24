local M = {}

M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local diagnostic_config = {
    virtual_text = false,
    signs = {
      active = signs
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    }
  }
  vim.diagnostic.config(diagnostic_config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client)
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec(
    [[
    augroup lsp_document_highlight
    autocmd! * <buffer>
    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]],
    false
    )
  end
end

-- TODO: may add custom keybinds for specific server here .. this can seperates config file per server just like the server setting files
-- local function lsp_keymaps(bufnr)
--   local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
--   local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
--
--   -- Enable completion triggerd by <C-x><C-o>
--   buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
--
--   local opts = { noremap = true, silent = true }
--   buf_set_keymap("n", "<leader>ff", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
--   buf_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)
--   buf_set_keymap('n', 'gt', "<cmd>Telescope lsp_type_definitions<CR>", opts)
--   buf_set_keymap('n', 'gx', "<cmd>Telescope lsp_code_actions<CR>", opts)
--   buf_set_keymap('x', 'gx', "<cmd>Telescope lsp_range_code_actions<CR>", opts)
--   buf_set_keymap('n', 'gr', "<cmd>Telescope lsp_references<CR>", opts)
--   buf_set_keymap('n', '<leader>ls', "<cmd>Telescope lsp_document_symbols<CR>", opts)
--   buf_set_keymap('n', '<leader>ld', "<cmd>Telescope diagnostics<CR>", opts)
--   buf_set_keymap('n', 'gs', "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
--   buf_set_keymap('n', 'gp', "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
--   -- buf_set_keymap('n', 'gh', "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
--   buf_set_keymap('n', ']d', "<cmd>lua vim.diagnostic.goto_next({ border = 'rounded'})<CR>", opts)
--   buf_set_keymap('n', '[d', "<cmd>lua vim.diagnostic.goto_prev({ border = 'rounded'})<CR>", opts)
--   buf_set_keymap('n', '<leader>lr', "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
-- end

M.on_attach = function(client, bufnr)
  if client.name == 'tsserver' then client.resolved_capabilities.document_formatting = false end

  -- lsp_keymaps(bufnr)
  lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not status_ok then return end

M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M
