local M = {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-colorscheme',
        'copilot-lualine',
    },
    event = 'UIEnter'
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
        end,
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
        symbols = { error = icons.diagnostics.error, warn = icons.diagnostics.warn },
        update_in_insert = false,
        always_visible = true,
    }

    -- local diff = {
    --     'diff',
    --     symbols = icons.git,
    --     cond = conditions.hide_in_width
    -- }

    local navic_location = {
        'navic',
        -- color_correction = 'dynamic',
        navic_opts = {
            separator = icons.lualine.navic_separator,
            highlight = false,
        }
        -- padding = { right = 0 }
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
            local msg, buf_filetype = 'no active lsp', vim.api.nvim_get_option_value('filetype', { buf = 0 })
            local matching_clients = {}

            for _, client in ipairs(vim.lsp.get_clients() or {}) do
                if client.config.filetypes and vim.fn.index(client.config.filetypes, buf_filetype) ~= -1 then
                    table.insert(matching_clients, client.name)
                end
            end

            return #matching_clients > 0 and table.concat(matching_clients, ', ') or msg
        end,
        icon = icons.lualine.lsp,
    }

    local session_status = {
        function()
            local fname_split = vim.split(vim.fn.fnamemodify(vim.v.this_session, ':t'), '__')
            return fname_split[#fname_split]
        end,
        icon = icons.lualine.session,
        padding = { left = 0, right = 1 },
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

    local copilot = {
        'copilot',
    }

    local hbac = {
        function()
            local cur_buf = vim.api.nvim_get_current_buf()
            local _, pinned = pcall(require('hbac.state').is_pinned, cur_buf)
            return pinned and '  pinned buffer' or ''
        end,
        color = { fg = '#ef5f6b', gui = 'bold' },
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
            lualine_x = { hbac, copilot, diagnostics },
            lualine_y = { lsp_status },
            lualine_z = { location },
        },
        tabline = {},
        extensions = { 'toggleterm', 'lazy', 'mason' }
    }
end

return M
