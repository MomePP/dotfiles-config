local telescope_keymap = require('config.keymaps').telescope

local M = {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
        { 'nvim-telescope/telescope-file-browser.nvim' },
        { 'nvim-telescope/telescope-fzf-native.nvim',  build = 'make' },
    },
}

M.opts = function()
    local defaults = require('config').defaults

    local utils = require('telescope.utils')
    local action_state = require('telescope.actions.state')

    local vertical_layout_config = {
        layout_strategy = 'vertical',
        layout_config = {
            preview_height = 0.7,
            prompt_position = 'bottom',
            width = 0.85,
            height = 0.8,
        },
        sorting_strategy = 'descending',
    }

    local horizontal_layout_config = {
        layout_strategy = 'horizontal',
        layout_config = {
            preview_width = 0.55,
            prompt_position = 'top',
            width = 0.85,
            height = 0.8,
        },
        sorting_strategy = 'ascending',
    }

    local bottom_layout_config = {
        layout_strategy = 'bottom_pane',
        layout_config = {
            height = 0.33,
            preview_width = 0.4,
            prompt_position = 'bottom'
        }
    }

    local function mergeConfig(conf1, conf2)
        return vim.tbl_deep_extend('force', conf1, conf2)
    end

    local function buffers_mapping(prompt_bufnr, map)
        local function delete_buf()
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
            local message = 'Selections to be removed: ' .. table.concat(buffers, ', ')
            vim.notify(string.format('[buffers.actions.remove] %s', message), vim.log.levels.INFO,
                { title = 'Telescope builtin' })

            vim.ui.input({ prompt = 'Remove selections ? [y/n] ' }, function(input)
                vim.cmd [[ redraw ]] -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt
                if input and input:lower() == 'y' then
                    -- INFO: lazy loads `mini.bufremove` for handles buffer deletion
                    require('lazy').load({ plugins = { 'mini.bufremove' } })

                    current_picker:delete_selection(function(selection)
                        local force = vim.api.nvim_get_option_value('buftype', { buf = selection.bufnr }) == 'terminal'
                        local ok = pcall(require('mini.bufremove').delete, selection.bufnr, force)
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

    return {
        defaults = {
            prompt_prefix = '   ',
            entry_prefix = '  ',
            selection_caret = '   ',
            results_title = '',
            color_devicons = true,
            path_display = { 'tail', 'smart' },
            set_env = { ['COLORTERM'] = 'truecolor' },
            file_ignore_patterns = { 'node_modules' },
            dynamic_preview_title = true,
            borderchars = defaults.float_border,
            mappings = {
                i = {
                    ['<C-q>'] = function(bufnr)
                        require 'telescope.actions'.smart_add_to_qflist(bufnr)
                        vim.cmd 'TroubleToggle quickfix'
                    end
                },
            },
            sorting_strategy = 'ascending',
            layout_strategy = 'flex',
            layout_config = {
                prompt_position = 'top',
            },
        },
        pickers = {
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
            lsp_references = mergeConfig(bottom_layout_config, {
                layout_config = {
                    preview_width = 0.5,
                },
                include_current_line = true,
                trim_text = true,
            }),
            buffers = mergeConfig(horizontal_layout_config, {
                attach_mappings = buffers_mapping
            }),
            quickfix = mergeConfig(vertical_layout_config, {
                layout_config = {
                    preview_height = 0.5,
                }
            }),
            help_tags = horizontal_layout_config,
            live_grep = vertical_layout_config,
            grep_string = vertical_layout_config,
            current_buffer_fuzzy_find = vertical_layout_config,
        },
        extensions = {
            ['fzf'] = {
                fuzzy = true,                   -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true,    -- override the file sorter
                case_mode = 'smart_case',       -- or 'ignore_case' or 'respect_case'
            },
            ['file_browser'] = mergeConfig(horizontal_layout_config, {
                path = '%:p:h',
                cwd_to_path = true,
                respect_gitignore = false,
                hidden = true,
                grouped = true,
                hijack_netrw = true,
            }),
        }
    }
end

M.config = function(_, opts)
    local telescope = require('telescope')

    telescope.setup(opts)
    telescope.load_extension('fzf')
    telescope.load_extension('file_browser')

    local telescope_augroup = vim.api.nvim_create_augroup('UserTelescopeAugroup', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        desc = 'disable cursorline when on telescope prompt',
        group = telescope_augroup,
        pattern = 'TelescopePrompt',
        command = ':setlocal nocursorline'
    })
end

M.keys = function()
    local function getVisualSelection()
        vim.cmd('noau normal! "vy"')
        local text = vim.fn.getreg('v')
        vim.fn.setreg('v', {})

        text = string.gsub(text, '\n', '')
        if #text > 0 then return text else return '' end
    end

    return {
        { telescope_keymap.resume,           '<Cmd>Telescope resume<CR>' },
        { telescope_keymap.buffers,          '<Cmd>Telescope buffers<CR>' },
        { telescope_keymap.jumplist,         '<Cmd>Telescope jumplist<CR>' },
        { telescope_keymap.help_tags,        '<Cmd>Telescope help_tags<CR>' },
        { telescope_keymap.file_browse,      '<Cmd>Telescope file_browser<CR>' },
        { telescope_keymap.find_files,       '<Cmd>Telescope find_files<CR>' },
        { telescope_keymap.oldfiles,         '<Cmd>Telescope oldfiles<CR>' },
        { telescope_keymap.search_workspace, '<Cmd>Telescope live_grep<CR>' },
        { telescope_keymap.grep_workspace,   '<Cmd>Telescope grep_string<CR>', mode = 'n' },
        {
            telescope_keymap.grep_workspace,
            function()
                require('telescope.builtin').grep_string {
                    default_text = ("'%s"):format(getVisualSelection()),
                    use_regex = false,
                }
            end,
            mode = 'v',
        },
    }
end

return M
