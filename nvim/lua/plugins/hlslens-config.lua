local M = {
    'kevinhwang91/nvim-hlslens',
}

M.opts = {
    calm_down = true,
    nearest_float_when = 'never',
    override_lens = function(render, posList, nearest, idx, relIdx)
        local sfw = vim.v.searchforward == 1
        local indicator, text, chunks
        local absRelIdx = math.abs(relIdx)
        if absRelIdx > 1 then
            indicator = ('%s %d'):format(sfw ~= (relIdx > 1) and '' or '', absRelIdx)
        elseif absRelIdx == 1 then
            indicator = sfw ~= (relIdx == 1) and '' or ''
        else
            indicator = ''
        end

        local lnum, col = unpack(posList[idx])
        if nearest then
            local cnt = #posList
            text = (' %s [%d/%d] '):format(indicator, idx, cnt)
            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
        else
            text = (' %s '):format(indicator)
            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
        end
        render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
    end
}

M.keys = function()
    local hlslens_keymap = require('config.keymaps').hlslens

    local function hlsPeekKeys(char)
        local ok, winid = require('hlslens').nNPeekWithUFO(char)
        if ok and winid then
            vim.keymap.set('n', '<CR>', function()
                vim.api.nvim_feedkeys(vim.keycode('<Tab><CR>'), 'im', false)
            end, { buffer = true })
        end
    end

    local function hlsSearchKeys(char)
        if pcall(vim.api.nvim_feedkeys, char, 'n', true) then
            require('hlslens').start()
        end
    end

    -- INFO: setup keybinding
    return {
        { hlslens_keymap.search_next, function() hlsPeekKeys(hlslens_keymap.search_next) end, mode = { 'n', 'x' } },
        { hlslens_keymap.search_prev, function() hlsPeekKeys(hlslens_keymap.search_prev) end, mode = { 'n', 'x' } },
        { hlslens_keymap.word_next,   function() hlsSearchKeys(hlslens_keymap.word_next) end },
        { hlslens_keymap.word_prev,   function() hlsSearchKeys(hlslens_keymap.word_prev) end },
        { hlslens_keymap.go_next,     function() hlsSearchKeys(hlslens_keymap.go_next) end },
        { hlslens_keymap.go_prev,     function() hlsSearchKeys(hlslens_keymap.go_prev) end },
    }
end

return M
