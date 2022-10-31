
local status_ok, indent_o_matic = pcall(require, 'indent-o-matic')
if not status_ok then return end

indent_o_matic.setup {
    standard_widths = { 2, 4 },
    filetype_ = {
        standard_widths = { 4 },
    }
}
