local status_ok, leap = pcall(require, 'leap')
if not status_ok then return end

local colors = require('colorscheme').colorset

-- set default keymap
leap.add_default_mappings()
leap.opts.highlight_unlabeled_phase_one_targets = true

-- greyout search area of `leap.nvim`
vim.api.nvim_set_hl(0, 'LeapBackdrop', { fg = 'grey', nocombine = true })
vim.api.nvim_set_hl(0, 'LeapLabelPrimary', { fg = 'cyan', bold = true, nocombine = true })
vim.api.nvim_set_hl(0, 'LeapLabelSecondary', { fg = colors.purple, bold = true, nocombine = true })
vim.api.nvim_set_hl(0, 'LeapMatch', { fg = 'white', bold = true, nocombine = true })
