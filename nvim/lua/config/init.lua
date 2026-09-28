local M = {
    did_init = false
}

M.defaults = {
    icons = {
        git = {
            added = ' ',
            modified = ' ',
            removed = ' ',
        },
        lualine = {
            git = '󰘬',
            search = ' ',
            session = '󰥿',
            location = ' ',
            lsp = ' '
        },
        bento = {
            pinned = '',
        }
    },
}

M.init = function()
    if not M.did_init then
        M.did_init = true

        require 'config.options'
        require 'zpack-config'
    end
end

M.setup = function()
    local function load_user_configs()
        require 'config.autocommands'
        require 'config.keymaps'.setup()
    end

    if vim.fn.argc(-1) == 0 then
        -- load user opts once the UI attaches (UIEnter)
        vim.api.nvim_create_autocmd('UIEnter', {
            group = vim.api.nvim_create_augroup('UserConfig', { clear = true }),
            callback = function()
                vim.schedule(function() load_user_configs() end)
            end,
        })
    else
        load_user_configs()
    end
end

return M
