local status_ok, incline = pcall(require, 'incline')
if not status_ok then return end

incline.setup {
    highlight = {
        groups = {
            InclineNormal = {
                guifg = '#e4e4e4',
                guibg = '#6100e0',
                gui = 'bold'
            },
            InclineNormalNC = {
                guifg = '#5F6672',
                guibg = 'None',
            }
        }
    },
    render = function(props)
		local bufname = vim.api.nvim_buf_get_name(props.buf)
		if bufname == "" then
			return "[No name]"
		else
			return vim.fn.fnamemodify(bufname, ":.")
		end
	end,
    window = {
        margin = {
            horizontal = 0,
            vertical = 0,
        }
    }
}

