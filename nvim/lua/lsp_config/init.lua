local nvim_lsp = require('lspconfig')
local protocol = require('vim.lsp.protocol')

local on_attach = function(client, bufnr)
	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
	local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
	
  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings --
	local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
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
  buf_set_keymap('n', '[d', "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
  buf_set_keymap('n', ']d', "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
  buf_set_keymap('n', '<leader>lr', "<cmd>Lspsaga rename<CR>", opts)

  -- formatting when save file
  -- if client.resolved_capabilities.document_formatting then
  --   vim.api.nvim_command [[augroup Format]]
  --   vim.api.nvim_command [[autocmd! * <buffer>]]
  --   vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
  --   vim.api.nvim_command [[augroup END]]
  -- end
  
  --protocol.SymbolKind = { }
  protocol.CompletionItemKind = {
    '', -- Text
    '', -- Method
    '', -- Function
    '', -- Constructor
    '', -- Field
    '', -- Variable
    '', -- Class
    'ﰮ', -- Interface
    '', -- Module
    '', -- Property
    '', -- Unit
    '', -- Value
    '', -- Enum
    '', -- Keyword
    '﬌', -- Snippet
    '', -- Color
    '', -- File
    '', -- Reference
    '', -- Folder
    '', -- EnumMember
    '', -- Constant
    '', -- Struct
    '', -- Event
    'ﬦ', -- Operator
    '', -- TypeParameter
  }
end

-- Set up completion using nvim_cmp with LSP source
local capabilities = require('cmp_nvim_lsp').update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

nvim_lsp.ccls.setup {
	on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    cache = {
      directory = ".ccls-cache"
    }
  }
}

nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" }
}

nvim_lsp.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

-- icon
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    -- This sets the spacing and the prefix, obviously.
    virtual_text = {
      spacing = 4,
      prefix = ''
    }
  }
)

