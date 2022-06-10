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
        signs = true,
        update_in_insert = false,
        underline = {
            severity = {
                vim.diagnostic.severity.ERROR,
                vim.diagnostic.severity.WARN
            }
        },
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
    local status_ok, illuminate = pcall(require, 'illuminate')
    if not status_ok then
        return
    end
    illuminate.on_attach(client)
end

M.on_attach = function(client, bufnr)
    if client.name == 'tsserver' then client.resolved_capabilities.document_formatting = false end

    lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not status_ok then
    M.capabilities = capabilities
else
    M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
end

return M
