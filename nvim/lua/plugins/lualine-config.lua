local M = {
    'nvim-lualine/lualine.nvim',
    event = 'VimEnter'
}

M.opts = function()
    local colors = require('plugins.colorscheme').colorset
    local icons = require('config').defaults.icons

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
            return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
            local filepath = vim.fn.expand('%:p:h')
            local gitdir = vim.fn.finddir('.git', filepath .. ';')
            return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
        check_session_exist = function()
            return vim.v.this_session ~= ''
        end
    }

    local mode = {
        'mode',
        fmt = function(mode_string)
            return string.format('%-7s', mode_string)
        end,
    }

    local diagnostics = {
        'diagnostics',
        sections = { 'error', 'warn' },
        symbols = { error = icons.diagnostics.Error, warn = icons.diagnostics.Warn },
        update_in_insert = false,
        always_visible = true,
    }

    -- local diff = {
    --     'diff',
    --     symbols = icons.git,
    --     cond = conditions.hide_in_width
    -- }

    local navic_location = {
        function()
            local navic_text = require('nvim-navic').get_location()
            if #navic_text ~= 0 then
                return navic_text
            else
                return ''
            end
        end,
        cond = require('nvim-navic').is_available,
        padding = { left = 1, right = 0 }
    }

    -- local filetype = {
    --     'filetype',
    --     icon_only = true,
    --     separator = '',
    --     padding = { right = 0, left = 1 }
    -- }

    -- local filename = {
    --     'filename',
    --     file_status = false, -- displays file status (readonly status, modified status)
    --     path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
    --     color = { gui = 'bold' },
    --     padding = { right = 0, left = 1 },
    --     cond = conditions.buffer_not_empty
    -- }

    local branch = {
        'branch',
        icons_enabled = true,
        icon = icons.lualine.git,
    }

    local lsp_status = {
        function()
            local msg = 'no active lsp'
            local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
            local clients = vim.lsp.get_active_clients()
            if next(clients) == nil then
                return msg
            end
            for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                end
            end
            return msg
        end,
        icon = icons.lualine.lsp,
    }

    local session_status = {
        function()
            local fname = vim.fn.fnamemodify(vim.v.this_session, ':t')
            local fname_split = vim.split(fname, '__')
            return fname_split[#fname_split]
        end,
        icon = icons.lualine.session,
        padding = { left = -1, right = 1 },
        cond = conditions.check_session_exist
    }

    local location = {
        function()
            return '[%3l/%3L] :%2v'
        end
    }

    local spacing = {
        function()
            return '%='
        end,
    }

    return {
        options = {
            icons_enabled = true,
            theme = colors.lualine,
            section_separators = '',
            component_separators = '',
            always_divide_middle = true,
        },
        sections = {
            lualine_a = { mode },
            lualine_b = { session_status },
            lualine_c = { branch, spacing, navic_location },
            lualine_x = { diagnostics },
            lualine_y = { lsp_status },
            lualine_z = { location },
        },
        tabline = {},
        extensions = { 'toggleterm' }
    }
end

return M
