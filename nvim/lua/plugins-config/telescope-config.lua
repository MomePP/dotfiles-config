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
                preview_width = 0.6
            }
        },
        lsp_references = {
            layout_strategy = 'bottom_pane',
            layout_config = {
                height = 0.4,
                preview_width = 0.4,
                prompt_position = 'bottom'
            },
            entry_maker = entry_lsp_references()
        },
        diagnostics = {
            layout_strategy = 'bottom_pane',
            layout_config = {
                height = 0.4,
                preview_width = 0.4,
                prompt_position = 'bottom'
            },
            line_width = 0.7
        },
        lsp_code_actions = {
            theme = 'cursor'
        },
        grep_string = {
            layout_strategy = 'horizontal',
        },
        current_buffer_fuzzy_find = {
            layout_strategy = 'vertical',
        },
        buffers = {
            layout_strategy = 'horizontal',
            layout_config = {
                preview_width = 0.6
            }
        }
    },
    extensions = {
        ['fzf'] = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
        ['file_browser'] = {
            layout_strategy = 'horizontal',
            layout_config = {
                preview_width = 0.6,
            },
            path = "%:p:h",
            cwd_to_path = true,
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            hijack_netrw = true,
        },
    }
}
telescope.load_extension("fzf")
telescope.load_extension("file_browser")


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
