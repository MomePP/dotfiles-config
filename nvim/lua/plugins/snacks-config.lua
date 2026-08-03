local M = {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000
}

local target_term_id = vim.v.count1

local bit = require('bit')
local GAP = '  '
-- widths: perms is always 9; `999.9k` is the widest common size; `%b %d %H:%M`
-- is 12 (the out-of-year `%b %d %Y` form is 11 and left-aligns into it).
local SIZE_WIDTH, TIME_WIDTH = 6, 12

-- INFO: these mirror canola.nvim's oil columns so a picker row reads like an oil
-- buffer — see lua/oil/adapters/files.lua (size, mtime) and
-- lua/oil/adapters/files/permissions.lua (mode_to_str). Copied rather than
-- require()d: zpack's module loader packadds the owning plugin on first require,
-- so pulling in oil.* here would eagerly load oil the moment the picker draws
-- instead of on its keymap. Keep the columns below in sync with oil-config.lua.
local function perm_to_str(exe_modifier, num)
    local str = (bit.band(num, 4) ~= 0 and 'r' or '-') .. (bit.band(num, 2) ~= 0 and 'w' or '-')
    if not exe_modifier then
        return str .. (bit.band(num, 1) ~= 0 and 'x' or '-')
    end
    -- setuid/setgid/sticky replace the x slot, upper-cased when x is unset
    return str .. (bit.band(num, 1) ~= 0 and exe_modifier or exe_modifier:upper())
end

local function mode_to_str(mode)
    local extra = bit.rshift(mode, 9)
    return perm_to_str(bit.band(extra, 4) ~= 0 and 's', bit.rshift(mode, 6))
        .. perm_to_str(bit.band(extra, 2) ~= 0 and 's', bit.rshift(mode, 3))
        .. perm_to_str(bit.band(extra, 1) ~= 0 and 't', mode)
end

-- NOTE: oil counts in decimal units (1e3), not 1024.
local function format_size(size)
    if size >= 1e9 then return ('%.1fG'):format(size / 1e9) end
    if size >= 1e6 then return ('%.1fM'):format(size / 1e6) end
    if size >= 1e3 then return ('%.1fk'):format(size / 1e3) end
    return ('%d'):format(size)
end

local function format_mtime(sec)
    local fmt = os.date('%Y', sec) == os.date('%Y') and '%b %d %H:%M' or '%b %d %Y'
    return os.date(fmt, sec)
end

-- INFO: oil-style columns in front of the stock file formatter, so a row reads:
-- permissions, size, mtime, icon, filename, dir. Fixed-width leading parts are
-- measured by snacks' layout pass, so the (deferred) path part truncates itself
-- around them with no extra padding maths here.
--
-- format() only runs for the rows currently VISIBLE (snacks list:render loops
-- top..top+height), so the per-row fs_stat costs one window's worth of syscalls
-- per redraw, not one per candidate.
local function file_details(item, picker)
    local snacks = require('snacks')
    local ret = snacks.picker.format.file(item, picker)

    local path = snacks.picker.util.path(item)
    local stat = path and vim.uv.fs_stat(path)
    if not stat then return ret end

    -- NOTE: fs_stat follows symlinks, so a link reports its target's mode/size.
    -- oil renders an empty column as a dimmed `-`; directories have no size.
    local size, size_hl = format_size(stat.size), nil
    if stat.type == 'directory' then size, size_hl = '-', 'SnacksPickerDimmed' end

    local align = snacks.picker.util.align
    local details = {
        { mode_to_str(stat.mode) },                          { GAP },
        { align(size, SIZE_WIDTH), size_hl },                { GAP },
        { align(format_mtime(stat.mtime.sec), TIME_WIDTH) }, { GAP },
    }
    return vim.list_extend(details, ret)
end

M.opts = function()
    local keymaps = require('config.keymaps').snacks
    local picker_keymap = keymaps.picker

    local fullscreen_layout = {
        layout = {
            box = 'vertical',
            backdrop = false,
            row = 0,
            width = 0,
            height = vim.o.lines - 1,
            border = 'none',
            { win = 'preview', title = '{preview}', border = 'vpad' },
            {
                box = 'vertical',
                height = 0.25,
                { win = 'input', border = 'solid', height = 1, title = ' {title} {live} {flags}', title_pos = 'left' },
                { win = 'list',  border = 'hpad' },
            },
        }
    }

    local select_layout = {
        preview = false,
        layout = {
            box = 'vertical',
            backdrop = false,
            width = 0.3,
            min_width = 40,
            height = 0.4,
            min_height = 3,
            { win = 'input', border = 'solid', height = 1, title = '{title}' },
            { win = 'list',  border = 'hpad' },
        },
    }

    return {
        image = { enabled = false },
        picker = {
            ui_select = true,
            layout = fullscreen_layout,
            sources = {
                files = { hidden = true, format = file_details },
                select = { layout = select_layout },
                help = { confirm = 'vsplit' },
            },
            formatters = {
                file = { filename_first = true },
                selected = { show_always = true }
            },
            icons = {
                ui = {
                    selected = '▌ ',
                    unselected = '  ',
                }
            },
            actions = {
                send_to_qflist = function(picker)
                    picker:close()

                    local sel = picker:selected()
                    local items = #sel > 0 and sel or picker:items()

                    local qf = {} ---@type vim.quickfix.entry[]
                    for _, item in ipairs(items) do
                        qf[#qf + 1] = {
                            filename = require('snacks').picker.util.path(item),
                            bufnr = item.buf,
                            lnum = item.pos and item.pos[1] or 1,
                            col = item.pos and item.pos[2] or 1,
                            end_lnum = item.end_pos and item.end_pos[1] or nil,
                            end_col = item.end_pos and item.end_pos[2] or nil,
                            text = item.line or item.comment or item.label or item.name or item.detail or item.text,
                            pattern = item.search,
                            valid = true,
                        }
                    end

                    vim.fn.setqflist(qf)
                    require('snacks').picker.qflist()
                end
            },
            win = {
                input = {
                    keys = {
                        [picker_keymap.action_scroll_up] = { 'preview_scroll_up', mode = { 'i', 'n' } },
                        [picker_keymap.action_scroll_down] = { 'preview_scroll_down', mode = { 'i', 'n' } },
                        [picker_keymap.action_focus_preview] = { 'focus_preview', mode = { 'i', 'n' } },
                        [picker_keymap.action_select_all] = { 'select_all', mode = { 'i', 'n' } },
                        [picker_keymap.action_send_to_qflist] = { 'send_to_qflist', mode = { 'i', 'n' } },
                    }
                },
                list = {
                    keys = {
                        [picker_keymap.action_scroll_up] = 'preview_scroll_up',
                        [picker_keymap.action_scroll_down] = 'preview_scroll_down',
                        [picker_keymap.action_focus_preview] = 'focus_preview',
                        [picker_keymap.action_select_all] = 'select_all',
                        [picker_keymap.action_send_to_qflist] = 'send_to_qflist',
                    }
                }
            }
        },
        scratch = {
            name = 'Project Notes',
            ft = 'markdown',
            icon = { '󰠮', 'SnacksScratchTitle' },
            root = vim.fn.stdpath('data') .. '/notes',
            autowrite = true,
            filekey = {
                cwd = true,
                branch = false,
                count = false,
            },
            win = {
                width = 0.8,
                height = 0.8,
                border = 'solid',
                title_pos = 'left',
                footer_pos = 'right',
                keys = {
                    ['q'] = 'close',
                },
            },
        },
        terminal = {
            win = {
                height   = 0,
                width    = 0,
                relative = 'editor',
                position = 'float',
                border   = { '', '', '', ' ', ' ', ' ', ' ', ' ' },
                wo       = {
                    winhighlight =
                    'Normal:SnacksTerminalNormal,NormalNC:SnacksTerminalNormal,FloatBorder:SnacksTerminalBorder,FloatFooter:SnacksTerminalFooter',
                },
                bo       = {
                    filetype = 'snacks_terminal',
                },
                on_buf   = function(self)
                    -- NOTE: `on_buf` called before `on_win`
                    target_term_id = vim.b[self.buf].snacks_terminal.id
                end,
                on_win   = function(self)
                    -- INFO: show footer messages
                    local footer_msg = 'Running command: '
                    if type(self.cmd) == 'table' then
                        footer_msg = footer_msg .. table.concat(self.cmd, ' ')
                    else
                        footer_msg = self.cmd and
                            (footer_msg .. self.cmd) or
                            ('Terminal ID: ' .. target_term_id)
                    end
                    vim.api.nvim_win_set_config(self.win, { footer = footer_msg })

                    -- HACK: manually delete term buffer before destroy win
                    local function cleanup_term(terminal)
                        if vim.api.nvim_buf_is_loaded(terminal.buf) then
                            vim.api.nvim_buf_delete(terminal.buf, { force = true })
                        end
                        terminal:destroy()
                        vim.cmd.checktime()
                    end

                    -- INFO: if we have cmd finished clean up after close
                    local event = self.cmd and 'WinClosed' or 'TermClose'
                    self:on(event, function()
                        cleanup_term(self)
                    end, { buf = true })
                end,
            }
        }
    }
end

M.keys = function()
    local snacks = require('snacks')

    local keymaps = require('config.keymaps').snacks
    local picker_keymap = keymaps.picker
    local bufdetele_keymap = keymaps.bufdelete
    local terminal_keymap = keymaps.terminal
    local scratch_keymap = keymaps.scratch

    -- INFO: only mapped toggle key for no cmd terminal
    local terminal_toggle_opts = {
        win = {
            keys = {
                [terminal_keymap.toggle] = { 'toggle', mode = 't' }
            },
        }
    }

    return {
        { picker_keymap.resume,           function() snacks.picker.resume() end },
        { picker_keymap.buffers,          function() snacks.picker.buffers() end },
        { picker_keymap.jumplist,         function() snacks.picker.jumps() end },
        { picker_keymap.help_tags,        function() snacks.picker.help() end },
        { picker_keymap.find_files,       function() snacks.picker.files() end },
        { picker_keymap.oldfiles,         function() snacks.picker.recent() end },
        { picker_keymap.search_workspace, function() snacks.picker.grep() end },
        { picker_keymap.search_buffers,   function() snacks.picker.grep_buffers() end },
        { picker_keymap.grep_workspace,   function() snacks.picker.grep_word() end,   mode = { 'n', 'x' } },

        { bufdetele_keymap.delete,        function() snacks.bufdelete.delete() end },

        {
            scratch_keymap.toggle,
            function()
                snacks.scratch.open({
                    win = {
                        title = ' Project Notes - ' .. (vim.uv.cwd() or '') .. ' ',
                        on_win = function(self)
                            local fname = vim.api.nvim_buf_get_name(self.buf)
                            local stat = fname ~= '' and vim.uv.fs_stat(fname)
                            local footer = stat
                                and (' Updated: ' .. os.date('%d-%b-%Y %H:%M', stat.mtime.sec) .. ' ')
                                or ''
                            vim.api.nvim_win_set_config(self.win, { footer = footer })
                        end,
                    }
                })
            end
        },

        {
            terminal_keymap.toggle,
            function()
                -- NOTE: check target_term_id exist in terminal list
                local user_input      = vim.v.count ~= 0
                local check_term_id   = user_input and vim.v.count1 or target_term_id
                local terminals       = snacks.terminal.list()
                local matched         = false
                local last_checked_id = nil

                for _, terminal in ipairs(terminals) do
                    local term_id = vim.b[terminal.buf].snacks_terminal.id
                    if term_id then
                        if term_id == check_term_id then
                            matched = true
                            break
                        end
                        if not last_checked_id or (last_checked_id < check_term_id and term_id < check_term_id) then
                            last_checked_id = term_id
                        end
                    end
                end

                -- INFO: resolve final terminal id, fallback to prev id before target id in list
                local final_id = check_term_id
                if last_checked_id and not matched and not user_input then
                    final_id = last_checked_id
                end

                snacks.terminal.toggle(nil, vim.tbl_deep_extend('force', terminal_toggle_opts, {
                    count = final_id
                }))
            end
        },
        { terminal_keymap.lazygit,              function() snacks.terminal.toggle('lazygit') end },
        { terminal_keymap.lazygit_file_history, function() snacks.terminal.toggle('lazygit -f ' .. vim.fn.expand('%')) end }
    }
end

return M
