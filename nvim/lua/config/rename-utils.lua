-- NOTE: this function are came from
--     https://github.com/ViRu-ThE-ViRuS/configs/blob/master/nvim/lua/lsp-setup/handlers.lua
--     https://github.com/axieax/dotconfig/blob/main/nvim/lua/axie/plugins/lsp/rename.lua
local M = {}

---Calls vim.lsp.buf.rename without the symbol name as default placeholder text
M.rename_clean_placeholder = function()
    -- Override vim.ui.input function to remove default text
    local original_ui_input = vim.ui.input
    vim.ui.input = function(opts, on_confirm)
        opts.default = ""
        original_ui_input(opts, on_confirm)
        vim.ui.input = original_ui_input
    end

    M.rename_to_qflist()
end

-- populate qf list with changes (if multiple files modified)
M.rename_to_qflist = function()
    local position_params = vim.lsp.util.make_position_params()
    position_params.oldName = vim.fn.expand("<cword>")

    vim.ui.input({ prompt = 'Rename > ', default = position_params.oldName }, function(input)
        -- exit no changes
        if input == nil then
            vim.notify('aborted', vim.log.levels.WARN, { title = '[LSP] rename' })
            return
        end

        position_params.newName = input
        vim.lsp.buf_request(0, "textDocument/rename", position_params, function(err, result, ctx, config)
            -- result not provided, error at lsp end
            -- no changes made
            if not result or (not result.documentChanges and not result.changes) then
                vim.notify(
                    string.format(
                        'could not perform rename: %s -> %s',
                        position_params.oldName,
                        position_params.newName
                    ),
                    vim.log.levels.ERROR,
                    { title = '[LSP] rename', timeout = 500 }
                )
                return
            end

            -- apply changes
            vim.lsp.handlers["textDocument/rename"](err, result, ctx, config)

            local notification, entries = {}, {}
            local num_files, num_updates = 0, 0

            -- collect changes
            if result.documentChanges then
                for _, document in pairs(result.documentChanges) do
                    num_files = num_files + 1
                    local uri = document.textDocument.uri
                    local bufnr = vim.uri_to_bufnr(uri)

                    for _, edit in ipairs(document.edits) do
                        local start_line = edit.range.start.line + 1
                        local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]

                        table.insert(entries, {
                            bufnr = bufnr,
                            lnum = start_line,
                            col = edit.range.start.character + 1,
                            text = line
                        })
                    end

                    num_updates = num_updates + vim.tbl_count(document.edits)

                    local short_uri = string.sub(vim.uri_to_fname(uri), #vim.loop.cwd() + 2)
                    table.insert(
                        notification,
                        string.format('\t- %d in %s', vim.tbl_count(document.edits), short_uri)
                    )
                end
            end

            -- collect changes
            if result.changes then
                for uri, edits in pairs(result.changes) do
                    num_files = num_files + 1
                    local bufnr = vim.uri_to_bufnr(uri)

                    for _, edit in ipairs(edits) do
                        local start_line = edit.range.start.line + 1
                        local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]

                        table.insert(entries, {
                            bufnr = bufnr,
                            lnum = start_line,
                            col = edit.range.start.character + 1,
                            text = line
                        })
                    end

                    num_updates = num_updates + vim.tbl_count(edits)

                    local short_uri = string.sub(vim.uri_to_fname(uri), #vim.loop.cwd() + 2)
                    table.insert(
                        notification,
                        string.format('\t- %d in %s', vim.tbl_count(edits), short_uri)
                    )
                end
            end

            -- format notification header and content
            local notification_str = ''
            if num_files > 1 then
                -- add header
                table.insert(notification, 1, string.format(
                    'made %d change%s in %d files',
                    num_updates,
                    (num_updates > 1 and "s") or "",
                    num_files
                ))

                notification_str = table.concat(notification, '\n')
            else
                -- only 1 entry in notification table for the single file
                notification_str = string.format('made %s', notification[1]:sub(4))

                -- add word "change"/"changes" at this point
                local insert_loc = notification_str:find('in') or 0

                notification_str = table.concat({
                    notification_str:sub(1, insert_loc - 1),
                    string.format('change%s ', (num_updates > 1 and "s") or ""),
                    notification_str:sub(insert_loc)
                }, '')
            end

            vim.notify(notification_str, vim.log.levels.INFO, {
                title = string.format(
                    '[LSP] rename: %s -> %s',
                    position_params.oldName,
                    position_params.newName
                ),
                timeout = 2500,
            })

            -- set qflist if more than 1 file
            if num_files > 1 then
                vim.fn.setqflist(entries, 'r')
                vim.cmd('TroubleToggle quickfix')
            end
        end)
    end)
end

return M
