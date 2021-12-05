function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup{
  defaults = {
    file_sorter = require("telescope.sorters").get_fzy_sorter,
    prompt_prefix = " > ",
    color_devicons = true,

    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
    file_browser = {
      -- theme = 'ivy'
    }
  }
}

telescope.load_extension("fzy_native")
telescope.load_extension("file_browser")

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

