local telescope_keymap = require('config.keymaps').telescope

local M = {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',

    dependencies = {
        'nvim-telescope/telescope-file-browser.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
}

M.keys = {
    { telescope_keymap.grep_workspace, '<Cmd>Telescope grep_string<CR>', telescope_keymap.opts },
    { telescope_keymap.buffers, '<Cmd>Telescope buffers<CR>', telescope_keymap.opts },
    { telescope_keymap.help, '<Cmd>Telescope help_tags<CR>', telescope_keymap.opts },
    { telescope_keymap.jumplist, '<Cmd>Telescope jumplist<CR>', telescope_keymap.opts },
    { telescope_keymap.search_workspace, '<Cmd>Telescope live_grep<CR>', telescope_keymap.opts },
    { telescope_keymap.oldfiles, '<Cmd>Telescope oldfiles<CR>', telescope_keymap.opts },
    { telescope_keymap.search_buffer, '<Cmd>Telescope current_buffer_fuzzy_find<CR>', telescope_keymap.opts },
    { telescope_keymap.file_browse, '<Cmd>Telescope file_browser<CR>', telescope_keymap.opts },
    { telescope_keymap.find_files, '<Cmd>Telescope find_files<CR>', telescope_keymap.opts },
}

M.config = function()
    local default_config = require('config').defaults

    local telescope = require('telescope')

    local utils = require('telescope.utils')
    local action_state = require('telescope.actions.state')
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
            borderchars = default_config.float_border,
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
            buffers = mergeConfig(horizontal_layout_config, {
                attach_mappings = function(prompt_bufnr, map)
                    local delete_buf = function()
                        local current_picker = action_state.get_current_picker(prompt_bufnr)
                        local multi_selections = current_picker:get_multi_selection()

                        local buffers = vim.tbl_map(function(selection)
                            return utils.transform_path({}, selection.filename)
                        end, multi_selections)

                        if next(buffers) == nil then
                            local selection = action_state.get_selected_entry()
                            multi_selections = vim.tbl_extend('force', multi_selections, { selection })
                            buffers = { utils.transform_path({}, selection.filename) }
                        end

                        local removed = {}
                        local message = 'Selections to be deleted: ' .. table.concat(buffers, ', ')
                        vim.notify(string.format('[buffers.actions.remove] %s', message), vim.log.levels.INFO,
                            { title = 'Telescope builtin' })

                        vim.ui.input({ prompt = 'Remove selections [y/N]: ' }, function(input)
                            vim.cmd [[ redraw ]] -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt
                            if input and input:lower() == 'y' then
                                -- INFO: lazy loads `mini.bufremove` for handles buffer deletion
                                require('lazy').load({ plugins = { 'mini.bufremove' } })
                                local bufremove = require('mini.bufremove')

                                current_picker:delete_selection(function(selection)
                                    local force = vim.api.nvim_buf_get_option(selection.bufnr, 'buftype') == 'terminal'
                                    local ok = pcall(bufremove.delete, selection.bufnr, force)
                                    if ok then table.insert(removed, utils.transform_path({}, selection.filename)) end
                                    return ok
                                end)

                                vim.notify('[buffers.actions.remove] Removed: ' .. table.concat(removed, ', '),
                                    vim.log.levels.INFO,
                                    { title = 'Telescope builtin' })
                            else
                                vim.notify('[buffers.actions.remove] Removing selections aborted!', vim.log.levels.INFO,
                                    { title = 'Telescope builtin' })
                            end
                        end)
                    end

                    map('n', telescope_keymap.action_buffer_delete.n, delete_buf)
                    map('i', telescope_keymap.action_buffer_delete.i, delete_buf)
                    return true
                end
            }),
            help_tags = horizontal_layout_config,
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
                path = '%:p:h',
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
end

return M
