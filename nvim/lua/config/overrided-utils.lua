local default_border = require('config').defaults.float_border

local function get_prompt_text(prompt, default_prompt)
    local prompt_text = prompt or default_prompt
    if prompt_text:sub(-1) == ':' then
        prompt_text = '[' .. prompt_text:sub(1, -2) .. ']'
    end
    return prompt_text
end

local function override_ui_select()
    local Menu = require('nui.menu')
    local event = require('nui.utils.autocmd').event

    local UISelect = Menu:extend('UISelect')

    function UISelect:init(items, opts, on_done)
        local border_top_text = get_prompt_text(opts.prompt, '[Select Item]')
        local kind = opts.kind or 'unknown'
        local format_item = opts.format_item or function(item)
            return tostring(item.__raw_item or item)
        end

        local popup_options = {
            relative = 'editor',
            position = '50%',
            border = {
                style = default_border,
                text = {
                    top = border_top_text,
                    top_align = 'left',
                },
            },
            win_options = {
                winhighlight = 'Normal:Normal,FloatBorder:NormalFloat',
            },
            zindex = 999,
        }

        if kind == 'codeaction' then
            -- change position for codeaction selection
            popup_options.relative = 'cursor'
            popup_options.position = {
                row = 2,
                col = 0,
            }
        end

        local max_width = popup_options.relative == 'editor' and vim.o.columns - 4 or vim.api.nvim_win_get_width(0) - 4
        local max_height = popup_options.relative == 'editor' and math.floor(vim.o.lines * 80 / 100)
            or vim.api.nvim_win_get_height(0)

        local menu_items = {}
        for index, item in ipairs(items) do
            if type(item) ~= 'table' then
                item = { __raw_item = item }
            end
            item.index = index
            local item_text = string.sub(format_item(item), 0, max_width)
            menu_items[index] = Menu.item(item_text, item)
        end

        local menu_options = {
            min_width = vim.api.nvim_strwidth(border_top_text),
            max_width = max_width,
            max_height = max_height,
            lines = menu_items,
            on_close = function()
                on_done(nil, nil)
            end,
            on_submit = function(item)
                on_done(item.__raw_item or item, item.index)
            end,
        }

        UISelect.super.init(self, popup_options, menu_options)

        -- cancel operation if cursor leaves select
        self:on(event.BufLeave, function()
            on_done(nil, nil)
        end, { once = true })
    end

    local select_ui = nil

    vim.ui.select = function(items, opts, on_choice)
        assert(type(on_choice) == 'function', 'missing on_choice function')

        if select_ui then
            -- ensure single ui.select operation
            vim.api.nvim_err_writeln('busy: another select is pending!')
            return
        end

        select_ui = UISelect(items, opts, function(item, index)
            if select_ui then
                -- if it's still mounted, unmount it
                select_ui:unmount()
            end
            -- pass the select value
            on_choice(item, index)
            -- indicate the operation is done
            select_ui = nil
        end)

        select_ui:mount()
    end
end

local function override_floating_preview()
    local base_open_floating_preview = vim.lsp.util.open_floating_preview
    vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
        opts = opts or {}
        opts.focus = opts.focusable or false
        opts.offset_x = opts.offset_x or -2
        opts.offset_y = opts.offset_y or 0
        opts.border = default_border

        -- NOTE: padding contents
        for index, message in ipairs(contents) do
            contents[index] = string.format(' %s ', message)
        end
        return base_open_floating_preview(contents, syntax, opts, ...)
    end
end


return {
    override_ui_select = override_ui_select,
    override_floating_preview = override_floating_preview,
}
