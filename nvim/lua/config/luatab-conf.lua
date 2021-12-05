local status, luatab = pcall(require, "luatab")
if (not status) then return end

luatab.setup {
  separator = function() return '' end,
  tabline = function()
    local line = ''
    for i = 1, vim.fn.tabpagenr('$'), 1 do
        line = line .. luatab.helpers.cell(i)
    end
    line = line .. '%#TabLineFill#%='
    if vim.fn.tabpagenr('$') >= 1 then
        line = line .. '%#TabLine#%999X'
    end
    return line
  
  end
}

