local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then return end

local actions = require('telescope.actions')
local entry_display = require('telescope.pickers.entry_display')
local utils = require('telescope.utils')

-- custom entry makers for some components
local function entry_lsp_references(opts)
  opts = opts or {}

  local displayer = entry_display.create {
    separator = "│ ",
    items = {
      { width = 8 },
      { width = 0.75 },
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
    prompt_prefix = "   ",
    color_devicons = true,

    file_sorter = require("telescope.sorters").get_fzy_sorter,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

    mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-c>"] = actions.close,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

        ["<PageUp>"] = actions.results_scrolling_up,
        ["<PageDown>"] = actions.results_scrolling_down,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<C-l>"] = actions.complete_tag,
        ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
      },
      n = {
        ["<esc>"] = actions.close,
        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
        ["H"] = actions.move_to_top,
        ["M"] = actions.move_to_middle,
        ["L"] = actions.move_to_bottom,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,
        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

        ["<PageUp>"] = actions.results_scrolling_up,
        ["<PageDown>"] = actions.results_scrolling_down,

        ["?"] = actions.which_key,
      },
    },
  },
  pickers = {
    help_tags = {
      layout_strategy = 'vertical',
      layout_config = {
        width = 0.8,
        preview_height = 0.7
      }
    },
    lsp_references = {
      -- theme = 'ivy'
      layout_strategy = 'bottom_pane',
      layout_config = {
        preview_width = 0.35,
        prompt_position = 'bottom'
      },
      entry_maker = entry_lsp_references()
    },
    diagnostics = {
      -- theme = 'ivy'
      layout_strategy = 'bottom_pane',
      layout_config = {
        preview_width = 0.35,
        prompt_position = 'bottom'
      },
      line_width = 0.75
    },
    lsp_code_actions = {
      theme = 'cursor'
    },
    lsp_range_code_actions = {
      theme = 'ivy'
    }
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
    file_browser = {
      -- theme = 'ivy'
    },
    media_files = {
      -- filetypes whitelist
      -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
      filetypes = {"png", "webm", "jpg", "jpeg", "pdf", "webp"},
      find_cmd = "rg" -- find command (defaults to `fd`)
    }
  }
}

telescope.load_extension("fzy_native")
telescope.load_extension("file_browser")
telescope.load_extension("media_files")

_G.open_telescope = function()
  local first_arg = vim.v.argv[2]
  -- print("path: ", first_arg)
  if first_arg then
    if vim.fn.isdirectory(first_arg) == 1 then
      if first_arg == "." then
        first_arg = vim.fn.expand('%')
      end
      vim.api.nvim_set_current_dir(first_arg)
      telescope.extensions.file_browser.file_browser({cwd = first_arg, hidden = true})
    end
  end
end

vim.api.nvim_exec([[
augroup TelescopeOnEnter
autocmd!
autocmd VimEnter * lua open_telescope()
augroup END
]], false)

