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
                globals = { 'vim', 'use' },
            },
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.stdpath("config") .. "/lua"] = true,
                },
                maxPreload = 10000,
                preloadFileSize = 10000,
            },
            telemetry = { enable = false },
        },
    },
}
