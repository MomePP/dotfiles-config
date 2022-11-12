local status_ok, hlslens = pcall(require, 'hlslens')
if not status_ok then return end

hlslens.setup({
    calm_down = true,
    override_lens = function(render, posList, nearest, idx, relIdx)
        local sfw = vim.v.searchforward == 1
        local indicator, text, chunks
        local absRelIdx = math.abs(relIdx)
        if absRelIdx > 1 then
            indicator = ('%d%s'):format(absRelIdx, sfw ~= (relIdx > 1) and '▲' or '▼')
        elseif absRelIdx == 1 then
            indicator = sfw ~= (relIdx == 1) and '▲' or '▼'
        else
            indicator = ''
        end

        local lnum, col = unpack(posList[idx])
        if nearest then
            local cnt = #posList
            if indicator ~= '' then
                text = ('[%s %d/%d]'):format(indicator, idx, cnt)
            else
                text = ('[%d/%d]'):format(idx, cnt)
            end
            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
        else
            text = ('[%s %d]'):format(indicator, idx)
            chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
        end
        render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
    end
})


local hlslens_keymap = require('keymappings').hlslens

local function hlsSearchKeys(c)
    if pcall(vim.api.nvim_feedkeys, c, 'n', true) then
        hlslens.start()
    end
end

vim.keymap.set('n', hlslens_keymap.search_next,
    function()
        hlslens.nNPeekWithUFO(hlslens_keymap.search_next)
    end, hlslens_keymap.opts)

vim.keymap.set('n', hlslens_keymap.search_prev,
    function()
        hlslens.nNPeekWithUFO(hlslens_keymap.search_prev)
    end, hlslens_keymap.opts)

vim.keymap.set('n', hlslens_keymap.word_next,
    function()
        hlsSearchKeys(hlslens_keymap.word_next)
    end, hlslens_keymap.opts)

vim.keymap.set('n', hlslens_keymap.word_prev,
    function()
        hlsSearchKeys(hlslens_keymap.word_prev)
    end, hlslens_keymap.opts)

vim.keymap.set('n', hlslens_keymap.go_next,
    function()
        hlsSearchKeys(hlslens_keymap.go_next)
    end, hlslens_keymap.opts)

vim.keymap.set('n', hlslens_keymap.go_prev,
    function()
        hlsSearchKeys(hlslens_keymap.go_prev)
    end, hlslens_keymap.opts)
