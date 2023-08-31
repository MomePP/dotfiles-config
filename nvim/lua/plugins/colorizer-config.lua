local M = {
    'NvChad/nvim-colorizer.lua',
    event = { 'BufReadPost', 'BufNewFile' }
}

M.opts = {
    user_default_options = {
        RGB = false,         -- #RGB hex codes
        RRGGBB = true,       -- #RRGGBB hex codes
        RRGGBBAA = true,     -- #RRGGBBAA hex codes
        AARRGGBB = false,    -- 0xAARRGGBB hex codes
        names = false,       -- "Name" codes like Blue or blue
        rgb_fn = false,      -- CSS rgb() and rgba() functions
        hsl_fn = false,      -- CSS hsl() and hsla() functions
        css = false,         -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false,      -- Enable all CSS *functions*: rgb_fn, hsl_fn
        mode = 'background', -- Set the display mode.
        virtualtext = '■',
    },
    filetypes = {
        'html',
        'css',
        'scss',
        'javascript',
        'typescript',
        'tsx',
        'vue',
        'svelte'
    },
}

return M
