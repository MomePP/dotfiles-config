local M = {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',

    dependencies = {
        'nvim-telescope/telescope-file-browser.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
}

M.config = function()
    local telescope = require('telescope')

    -- local actions = require 'telescope.actions'
    local utils = require('telescope.utils')
    local entry_display = require('telescope.pickers.entry_display')

    local vertical_layout_config = {
        layout_strategy = 'vertical',
        layout_config = {
            preview_height = 0.75,
            prompt_position = 'bottom'
        }
    }

    local horizontal_layout_config = {
        -- sorting_strategy = 'ascending',
        layout_strategy = 'horizontal',
        layout_config = {
            preview_width = 0.6,
            -- prompt_position = 'top'
        }
    }

    local bottom_layout_config = {
        layout_strategy = 'bottom_pane',
        layout_config = {
            height = 0.3,
            preview_width = 0.4,
            prompt_position = 'bottom'
        },

    }

    local function mergeConfig(conf1, conf2)
        return vim.tbl_deep_extend('force', conf1, conf2)
    end

    -- custom entry makers for some components
    local function entry_lsp_references(opts)
        opts = opts or {}

        local displayer = entry_display.create {
            separator = '│ ',
            items = {
                { width = 8 },
                { width = 0.65 },
                { remaining = true },
            },
        }

        local make_display = function(entry)
            local filename = utils.transform_path(opts, entry.filename)

            local line_info = { table.concat({ entry.lnum, entry.col }, ':'), 'TelescopeResultsLineNr' }

            return displayer {
                line_info,
                entry.text:gsub('.* | ', ''),
                filename,
            }
        end

        return function(entry)
            local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)

            return {
                valid = true,

                value = entry,
                ordinal = (not opts.ignore_filename and filename or '') .. ' ' .. entry.text,
                display = make_display,

                bufnr = entry.bufnr,
                filename = filename,
                lnum = entry.lnum,
                col = entry.col,
                text = entry.text,
                start = entry.start,
                finish = entry.finish,
            }
        end
    end

    telescope.setup {
        defaults = {
            prompt_prefix = '   ', -- this still got an issue of prompt buffer bug, can be workaround by changes it to empty string
            entry_prefix = '  ',
            selection_caret = '  ',
            color_devicons = true,
            path_display = { 'tail', 'smart' },
            set_env = { ['COLORTERM'] = 'truecolor' },
            file_ignore_patterns = { 'node_module' },
            borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
            dynamic_preview_title = true,
        },
        pickers = {
            lsp_references = mergeConfig(bottom_layout_config, {
                entry_maker = entry_lsp_references()
            }),
            diagnostics = mergeConfig(bottom_layout_config, {
                line_width = 0.7
            }),
            lsp_code_actions = {
                theme = 'cursor'
            },
            find_files = mergeConfig(horizontal_layout_config, {
                path_display = { 'smart' },
                wrap_results = true
            }),
            lsp_definitions = mergeConfig(bottom_layout_config, {
                layout_config = {
                    preview_width = 0.5,
                }
            }),
            help_tags = horizontal_layout_config,
            buffers = horizontal_layout_config,
            live_grep = vertical_layout_config,
            grep_string = vertical_layout_config,
            current_buffer_fuzzy_find = vertical_layout_config,
            quickfix = bottom_layout_config,
        },
        extensions = {
            ['fzf'] = {
                fuzzy = true, -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true, -- override the file sorter
                case_mode = 'smart_case', -- or 'ignore_case' or 'respect_case'
            },
            ['file_browser'] = mergeConfig(horizontal_layout_config, {
                path = "%:p:h",
                cwd_to_path = true,
                respect_gitignore = false,
                hidden = true,
                grouped = true,
                hijack_netrw = true,
            }),
            ['ui-select'] = {
                theme = 'cursor'
            },
        }
    }
    telescope.load_extension('fzf')
    telescope.load_extension('file_browser')
    telescope.load_extension('ui-select')

    -- INFO: setup keymap
    local telescope_builtin = require('telescope.builtin')
    local telescope_keymap = require('keymaps').telescope

    vim.keymap.set('n', telescope_keymap.grep_workspace, telescope_builtin.grep_string, telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.buffers, telescope_builtin.buffers, telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.help, telescope_builtin.help_tags, telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.jumplist, telescope_builtin.jumplist, telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.search_workspace, telescope_builtin.live_grep, telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.oldfiles, telescope_builtin.oldfiles, telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.search_buffer, telescope_builtin.current_buffer_fuzzy_find,
        telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.file_browse, telescope.extensions.file_browser.file_browser,
        telescope_keymap.opts)
    vim.keymap.set('n', telescope_keymap.find_files, telescope_builtin.find_files, telescope_keymap.opts)
end

return M
