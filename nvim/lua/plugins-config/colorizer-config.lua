local status_ok, colorizer = pcall(require, 'colorizer')
if not status_ok then return end

colorizer.setup({'*'}, {
    RGB = true,
    RRGGBB = true,
    RRGGBBAA = true,
    names = false,
    rgb_fn = false,
    hsl_fn = false,
    css = false,
    css_fn = false,

    -- Available modes: foreground, background
    mode = 'background',
})

