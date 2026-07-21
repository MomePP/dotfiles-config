local M = {
    'stevearc/resession.nvim',
    lazy = false,
}

M.config = function()
    local resession = require('resession')
    resession.setup {}

    -- WORKAROUND: nvim master regression (neovim/neovim commit 6a8bb2d62, PR #40674):
    -- bufload()'ed buffers turn spuriously 'modified' on first display, so resession's
    -- silent `:edit` (which triggers filetype + treesitter) aborts with a hidden E37.
    -- Clear the bogus flag so the :edit succeeds. Guarded by comparing buffer content
    -- against the file on disk, so real edits are never discarded; harmless no-op on
    -- stable/fixed builds. TODO: remove once fixed upstream.
    local function spurious_modified(buf)
        if not vim.bo[buf].modified or vim.bo[buf].buftype ~= '' then
            return false
        end
        local name = vim.api.nvim_buf_get_name(buf)
        if name == '' or vim.fn.filereadable(name) ~= 1 then
            return false
        end
        local ok, disk = pcall(vim.fn.readfile, name)
        return ok and vim.deep_equal(disk, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
    end
    -- registered at setup time so it runs BEFORE resession's own per-buffer
    -- BufEnter (autocmds fire in creation order), letting its `:edit` succeed
    vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('resession.modified_workaround', {}),
        callback = function(args)
            if vim.b[args.buf]._resession_need_edit and spurious_modified(args.buf) then
                vim.bo[args.buf].modified = false
            end
        end,
    })
    resession.add_hook('post_load', function()
        -- heal every *visible* buffer: non-current windows never fire the
        -- deferred BufEnter -> :edit until focused, so they'd sit displayed
        -- as modified/unhighlighted. The current buffer only needs its flag
        -- cleared — resession runs its own final `:edit` right after.
        local curwin = vim.api.nvim_get_current_win()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if spurious_modified(buf) then
                vim.bo[buf].modified = false
                if win ~= curwin then
                    vim.api.nvim_win_call(win, function()
                        vim.b[buf]._resession_need_edit = nil
                        vim.cmd.edit({ mods = { emsg_silent = true } })
                    end)
                end
            end
        end
    end)

    -- NOTE: load a dir-specific session when open nvim, save when exit.
    vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
            if vim.fn.argc(-1) == 0 then
                resession.load(vim.fn.getcwd(), { silence_errors = true })
            end
        end,
        nested = true,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
            -- NOTE: save only exist session
            local files = require('resession.files')
            local current_session = string.format('%s', vim.fn.getcwd():gsub(files.sep, '_'):gsub(':', '_'))

            for _, session_name in ipairs(resession.list()) do
                if session_name == current_session then
                    resession.save(vim.fn.getcwd(), { notify = true })
                    return
                end
            end
        end,
    })
end

M.keys = function()
    local resession_keymap = require('config.keymaps').resession

    return {
        { resession_keymap.save,   function() require('resession').save(vim.fn.getcwd()) end },
        { resession_keymap.delete, function() require('resession').delete() end },
    }
end

return M
