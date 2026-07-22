local M = {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = 'BufEnter',
    dependencies = {
        { 'nvim-treesitter/nvim-treesitter-context',     opts = { zindex = 5, max_lines = 3 } },
        { 'folke/ts-comments.nvim',                      opts = {} },
    },
}

M.config = function()
    local ensure_install = {
        'regex',
        'lua',
        'vim',
        'vimdoc',
        'markdown',
        'markdown_inline',
        'bash',
        'nu',
        'yaml',
        'tsx',
        'javascript',
        'css',
        'scss',
        'latex',
    }
    require('nvim-treesitter').install(ensure_install)

    -- NOTE: extra parser register if filetype not matched
    -- vim.treesitter.language.register('ini', { 'dosini', 'confini' }) -- supported
    vim.treesitter.language.register('jsonc', 'json')

    local installing = {}
    local lang_cache = {} -- filetype -> language | false
    local available_set -- lazy-built set of registry parsers

    vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter.setup', {}),
        callback = function(args)
            local buf = args.buf
            local ft = args.match

            -- resolve and cache filetype -> language mapping
            local language = lang_cache[ft]
            if language == nil then
                language = vim.treesitter.language.get_lang(ft) or ft
                lang_cache[ft] = (language ~= '') and language or false
            end
            if not language then
                return
            end

            if not vim.treesitter.language.add(language) then
                if installing[language] then
                    return
                end
                -- lazy-build available parser set once
                if not available_set then
                    available_set = {}
                    for _, l in ipairs(require('nvim-treesitter').get_available()) do
                        available_set[l] = true
                    end
                end
                if not available_set[language] then
                    lang_cache[ft] = false -- skip this filetype from now on
                    return
                end
                installing[language] = true
                require('nvim-treesitter').install(language)
                local timer = vim.uv.new_timer()
                timer:start(500, 500, vim.schedule_wrap(function()
                    if vim.treesitter.language.add(language) then
                        timer:stop()
                        timer:close()
                        installing[language] = nil
                        if vim.api.nvim_buf_is_valid(buf) then
                            vim.bo[buf].filetype = vim.bo[buf].filetype
                        end
                    end
                end))
                return
            end

            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.treesitter.start(buf, language)
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end

return M
