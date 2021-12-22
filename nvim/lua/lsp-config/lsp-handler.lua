local M = {}

M.setup = function()
  local diagnostic_config = {
    virtual_text = false,
    signs = {
      active = signs,
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
end

local function lsp_keymaps(bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggerd by <C-x><C-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  buf_set_keymap("n", "<leader>ff", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  buf_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)
  buf_set_keymap('n', 'gt', "<cmd>Telescope lsp_type_definitions<CR>", opts)
  buf_set_keymap('n', 'gx', "<cmd>Telescope lsp_code_actions<CR>", opts)
  buf_set_keymap('x', 'gx', "<cmd>Telescope lsp_range_code_actions<CR>", opts)
  buf_set_keymap('n', 'gr', "<cmd>Telescope lsp_references<CR>", opts)
  buf_set_keymap('n', '<leader>ls', "<cmd>Telescope lsp_document_symbols<CR>", opts)
  buf_set_keymap('n', '<leader>ld', "<cmd>Telescope diagnostics<CR>", opts)
  buf_set_keymap('n', 'gs', "<cmd>Lspsaga signature_help<CR>", opts)
  buf_set_keymap('n', 'gp', "<cmd>Lspsaga preview_definition<CR>", opts)
  buf_set_keymap('n', 'gh', "<cmd>Lspsaga hover_doc<CR>", opts)
  buf_set_keymap('n', ']d', "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
  buf_set_keymap('n', '[d', "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
  buf_set_keymap('n', '<leader>lr', "<cmd>Lspsaga rename<CR>", opts)
end

M.on_attach = function(client, bufnr)
  if client.name == 'tsserver' then client.resolved_capabilities.document_formatting = false end

  lsp_keymaps(bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not status_ok then return end

M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M
      
