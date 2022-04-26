local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then return end

-- local actions = require "telescope.actions"
local utils = require "telescope.utils"
local entry_display = require "telescope.pickers.entry_display"

-- custom entry makers for some components
local function entry_lsp_references(opts)
    opts = opts or {}

    local displayer = entry_display.create {
        separator = "│ ",
        items = {
            { width = 8 },
            { width = 0.65 },
            { remaining = true },
        },
    }

    local make_display = function(entry)
        local filename = utils.transform_path(opts, entry.filename)

        local line_info = { table.concat({ entry.lnum, entry.col }, ":"), "TelescopeResultsLineNr" }

        return displayer {
            line_info,
            entry.text:gsub(".* | ", ""),
            filename,
        }
    end

    return function(entry)
        local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)

        return {
            valid = true,

            value = entry,
            ordinal = (not opts.ignore_filename and filename or "") .. " " .. entry.text,
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
        prompt_prefix = "   ", -- this still got an issue of prompt buffer bug, can be workaround by changes it to empty string
        entry_prefix = "  ",
        selection_caret = "  ",
        color_devicons = true,
        path_display = { "tail", "smart" },
        set_env = { ["COLORTERM"] = "truecolor" },
        file_ignore_patterns = { "node_module" },
    },
    pickers = {
        help_tags = {
            layout_strategy = 'horizontal',
            layout_config = {
                preview_width = 0.65
            }
        },
        lsp_references = {
            -- theme = 'ivy'
            layout_strategy = 'bottom_pane',
            layout_config = {
                height = 0.4,
                preview_width = 0.4,
                prompt_position = 'bottom'
            },
            entry_maker = entry_lsp_references()
        },
        diagnostics = {
            -- theme = 'ivy'
            layout_strategy = 'bottom_pane',
            layout_config = {
                height = 0.4,
                preview_width = 0.4,
                prompt_position = 'bottom'
            },
            line_width = 0.65
        },
        lsp_code_actions = {
            theme = 'cursor'
        },
        lsp_range_code_actions = {
            layout_strategy = 'center'
        },
        grep_string = {
            layout_strategy = 'horizontal',
        },
        current_buffer_fuzzy_find = {
            layout_strategy = 'vertical',
        }
    },
    extensions = {
        ['fzf'] = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        },
        ['file_browser'] = {
            layout_strategy = 'horizontal',
            layout_config = {
                preview_width = 0.65
            },
            respect_gitignore = false,
        },
        ['ui-select'] = {
            require('telescope.themes').get_cursor()
        }
    }
}
telescope.load_extension("fzf")
telescope.load_extension("file_browser")
telescope.load_extension("ui-select")

-- INFO: custom telescope to launch when entering nvim
vim.api.nvim_create_augroup('TelescopeOnEnter', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
    desc = 'launch telescope as file explorer when enter nvim',
    group = 'TelescopeOnEnter',
    pattern = '*',
    callback = function ()
        local first_arg = vim.v.argv[2]
        -- print("path: ", first_arg)
        if first_arg and vim.fn.isdirectory(first_arg) ~= 0 then
            -- local pathList = vim.split(first_arg, '/')
            -- for _, value in pairs(pathList) do
            --     if value == "." then
            --         print('found dir.. ' .. first_arg)
            --         break
            --     end
            -- end
            first_arg = vim.fn.expand('%:p')
            vim.api.nvim_set_current_dir(first_arg)
            telescope.extensions.file_browser.file_browser({cwd = first_arg})
        end
    end
})


-- INFO: custom telescope pickers
local custom_telescope = {}
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values

function custom_telescope.marks_picker(opts)
    require('marks').mark_state:all_to_list() -- generate marks to loclist

    local filenames = {}
    local locations = vim.fn.getloclist(0) -- marks.nvim uses loclist 0 for store marked list
    if locations then
        for _, value in pairs(locations) do
            local bufnr = value.bufnr
            if filenames[bufnr] == nil then
                filenames[bufnr] = vim.api.nvim_buf_get_name(bufnr)
            end
            value.filename = filenames[bufnr]
        end
    end

    if vim.tbl_isempty(locations) then
        print('There is no marked - ')
        return
    end

    pickers.new(opts, {
        prompt_title = "Marks",
        finder = finders.new_table {
            results = locations,
            entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
        },
        previewer = conf.qflist_previewer(opts),
        sorter = conf.generic_sorter(opts),
    }):find()
end

return custom_telescope
