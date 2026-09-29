return {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            completion = {
                callSnippet = 'Replace',
            },
            diagnostics = {
                enable = true,
                globals = { 'vim' },
            },
            hint = {
                enable = true,
                arrayIndex = 'Disable',
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    '${3rd}/luv/library',
                },
            },
        },
    },
}
