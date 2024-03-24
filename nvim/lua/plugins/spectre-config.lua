local spectre_keymap = require('config.keymaps').spectre

local M = {
    'nvim-pack/nvim-spectre',
    dependencies = { 'grapp-dev/nui-components.nvim' },
}
local SpectreUI = {}

M.config = function()
    require('spectre').setup {}

    local spectre_search = require('spectre.search')
    local spectre_state = require('spectre.state')
    local spectre_state_utils = require('spectre.state_utils')
    local spectre_utils = require('spectre.utils')

    local Tree = require('nui.tree')
    local n = require('nui-components')

    local fn = require('config.fn-utils')

    -- INFO: ---------------------------------
    -- ---
    -- ---      Spectre engine
    -- ---
    local engine = {}

    local function search_handler(options, signal)
        local start_time = 0
        local total = 0

        spectre_state.groups = {}

        return {
            on_start = function()
                spectre_state.is_running = true
                start_time = vim.loop.hrtime()
            end,
            on_result = function(item)
                if not spectre_state.is_running then
                    return
                end

                if not spectre_state.groups[item.filename] then
                    spectre_state.groups[item.filename] = {}
                end

                table.insert(spectre_state.groups[item.filename], item)
                total = total + 1
            end,
            on_error = function(_) end,
            on_finish = function()
                if not spectre_state.is_running then
                    return
                end

                local end_time = (vim.loop.hrtime() - start_time) / 1E9

                signal.search_results = engine.process(options)
                signal.search_info = string.format("Total: %s match, time: %ss", total, end_time)

                spectre_state.finder_instance = nil
                spectre_state.is_running = false
            end,
        }
    end

    function engine.process(options)
        options = options or {}

        return fn.kmap(spectre_state.groups, function(group, filename)
            local children = fn.imap(group, function(entry)
                local id = tostring(math.random())

                local diff = spectre_utils.get_hl_line_text({
                    search_query = options.search_query,
                    replace_query = options.replace_query,
                    search_text = entry.text,
                    padding = 0,
                }, spectre_state.regex)

                return Tree.Node({ text = diff.text, _id = id, diff = diff, entry = entry })
            end)

            local id = tostring(math.random())
            local node = Tree.Node({ text = filename:gsub("^./", ""), _id = id }, children)

            node:expand()

            return node
        end)
    end

    function engine.stop()
        if not spectre_state.finder_instance then
            return
        end

        spectre_state.finder_instance:stop()
        spectre_state.finder_instance = nil
    end

    function engine.search(options, signal)
        options = options or {}

        engine.stop()

        local search_engine = spectre_search["rg"]
        spectre_state.options["ignore-case"] = not options.is_case_insensitive_checked
        spectre_state.finder_instance =
            search_engine:new(spectre_state_utils.get_search_engine_config(), search_handler(options, signal))
        spectre_state.regex = require("spectre.regex.vim")

        pcall(function()
            spectre_state.finder_instance:search({
                cwd = vim.fn.getcwd(),
                search_text = options.search_query,
                replace_query = options.replace_query,
                -- path = spectre_state.query.path,
                search_paths = #options.search_paths > 0 and options.search_paths or nil,
            })
        end)
    end

    -- INFO: ---------------------------------
    -- ---
    -- ---      search tree renderer
    -- ---
    local function replace_handler(tree, node)
        return {
            on_done = function(result)
                if result.ref then
                    node.ref = result.ref
                    tree:render()
                end
            end,
            on_error = function(_) end,
        }
    end

    local function mappings(search_query, replace_query)
        return function(component)
            return {
                {
                    mode = { "n" },
                    key = spectre_keymap.tree_replace,
                    handler = function()
                        local tree = component:get_tree()
                        local focused_node = component:get_focused_node()

                        if not focused_node then
                            return
                        end

                        local has_children = focused_node:has_children()

                        if not has_children then
                            local replacer_creator = spectre_state_utils.get_replace_creator()
                            local replacer =
                                replacer_creator:new(spectre_state_utils.get_replace_engine_config(),
                                    replace_handler(tree, focused_node))

                            local entry = focused_node.entry

                            replacer:replace({
                                lnum = entry.lnum,
                                col = entry.col,
                                cwd = vim.fn.getcwd(),
                                display_lnum = 0,
                                filename = entry.filename,
                                search_text = search_query:get_value(),
                                replace_text = replace_query:get_value(),
                            })
                        end
                    end,
                },
            }
        end
    end

    local function prepare_node(node, line, component)
        local _, devicons = pcall(require, "nvim-web-devicons")
        local has_children = node:has_children()

        line:append(string.rep("  ", node:get_depth() - 1))

        if has_children then
            local icon, icon_highlight = devicons.get_icon(node.text, string.match(node.text, "%a+$"), { default = true })

            line:append(node:is_expanded() and " " or " ", component:hl_group("SpectreIcon"))
            line:append(icon .. " ", icon_highlight)
            line:append(node.text, component:hl_group("SpectreFileName"))

            return line
        end

        local is_replacing = #node.diff.replace > 0
        local search_highlight_group = component:hl_group(is_replacing and "SpectreSearchOldValue" or
        "SpectreSearchValue")
        local default_text_highlight = component:hl_group("SpectreCodeLine")

        local _, empty_spaces = string.find(node.diff.text, "^%s*")
        local ref = node.ref

        if ref then
            line:append("✔ ", component:hl_group("SpectreReplaceSuccess"))
        end

        if #node.diff.search > 0 then
            local code_text = fn.trim(node.diff.text)

            fn.ieach(node.diff.search, function(value, index)
                local start = value[1] - empty_spaces
                local end_ = value[2] - empty_spaces

                if index == 1 then
                    line:append(string.sub(code_text, 1, start), default_text_highlight)
                end

                local search_text = string.sub(code_text, start + 1, end_)
                line:append(search_text, search_highlight_group)

                local replace_diff_value = node.diff.replace[index]

                if replace_diff_value then
                    local replace_text =
                        string.sub(code_text, replace_diff_value[1] + 1 - empty_spaces,
                            replace_diff_value[2] - empty_spaces)
                    line:append(replace_text, component:hl_group("SpectreSearchNewValue"))
                    end_ = replace_diff_value[2] - empty_spaces
                end

                if index == #node.diff.search then
                    line:append(string.sub(code_text, end_ + 1), default_text_highlight)
                end
            end)
        end

        return line
    end

    local function on_select(origin_winid)
        return function(node, component)
            local tree = component:get_tree()

            if node:has_children() then
                if node:is_expanded() then
                    node:collapse()
                else
                    node:expand()
                end

                return tree:render()
            end

            local entry = node.entry

            if vim.api.nvim_win_is_valid(origin_winid) then
                local escaped_filename = vim.fn.fnameescape(entry.filename)

                vim.api.nvim_set_current_win(origin_winid)
                vim.api.nvim_command([[execute "normal! m` "]])
                vim.cmd("e " .. escaped_filename)
                vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col - 1 })
            end
        end
    end

    local function search_tree(props)
        return n.tree({
            border_style = "none",
            flex = 1,
            padding = { left = 1, right = 1 },
            hidden = props.hidden,
            data = props.data,
            mappings = mappings(props.search_query, props.replace_query),
            prepare_node = prepare_node,
            on_select = on_select(props.origin_winid),
        })
    end


    -- INFO: ---------------------------------
    -- ---
    -- ---      SpectreUI
    -- ---
    function SpectreUI.toggle()
        if SpectreUI.renderer then
            return SpectreUI.renderer:focus()
        end

        local char_search_threshold = 3
        local editor_width = vim.o.columns
        local editor_height = vim.o.lines
        -- local win_width = vim.api.nvim_win_get_width(0)
        -- local win_height = vim.api.nvim_win_get_height(0)
        local width = 42
        local height = editor_height - 3
        -- local height = win_height - 3

        local renderer = n.create_renderer({
            width = width,
            height = height,
            relative = 'editor',
            -- relative = 'win',
            position = {
                row = 2,
                col = editor_width - width,
                -- col = win_width - width,
            },
        })

        local signal = n.create_signal({
            search_query = "",
            replace_query = "",
            search_paths = {},
            is_replace_field_visible = false,
            is_case_insensitive_checked = false,
            search_info = "",
            search_results = {},
        })

        local subscription = signal:observe(function(prev, curr)
            local diff = fn.isome({ "search_query", "is_case_insensitive_checked", "search_paths" }, function(key)
                return not vim.deep_equal(prev[key], curr[key])
            end)

            if diff then
                if #curr.search_query >= char_search_threshold then
                    engine.search(curr, signal)
                else
                    signal.search_info = ""
                    signal.search_results = {}
                end
            end

            if not (prev.replace_query == curr.replace_query) and #curr.search_query >= char_search_threshold then
                signal.search_results = engine.process(curr)
            end
        end)

        renderer:on_unmount(function()
            vim.api.nvim_set_current_win(renderer:get_origin_winid())
            subscription:unsubscribe()
            SpectreUI.renderer = nil
        end)

        SpectreUI.renderer = renderer

        local body = n.rows(n.columns(
            n.checkbox({
                default_sign = "→",
                checked_sign = "↓",
                padding = {
                    top = 1,
                    left = 1,
                },
                value = signal.is_replace_field_visible,
                on_change = function(is_checked)
                    signal.is_replace_field_visible = is_checked

                    if is_checked then
                        local replace_component = renderer:get_component_by_id("replace_query")

                        renderer:schedule(function()
                            replace_component:focus()
                        end)
                    end
                end,
            }),
            n.rows(
                n.columns(
                    { size = 3 },
                    n.text_input({
                        autofocus = true,
                        flex = 1,
                        max_lines = 1,
                        border_label = "Search",
                        on_change = fn.debounce(function(value)
                            signal.search_query = value
                        end, 400),
                    }),
                    n.checkbox({
                        label = "Aa",
                        default_sign = "",
                        checked_sign = "",
                        border_style = "rounded",
                        value = signal.is_case_insensitive_checked,
                        on_change = function(is_checked)
                            signal.is_case_insensitive_checked = is_checked
                        end,
                    })
                ),
                n.text_input({
                    size = 1,
                    max_lines = 1,
                    id = "replace_query",
                    border_label = "Replace",
                    on_change = fn.debounce(function(value)
                        signal.replace_query = value
                    end, 400),
                    hidden = signal.is_replace_field_visible:map(function(value) return not value end),
                }),
                n.text_input({
                    size = 1,
                    max_lines = 1,
                    border_label = "Files to include",
                    value = signal.search_paths:map(function(paths)
                        return table.concat(paths, ",")
                    end),
                    on_change = fn.debounce(function(value)
                        signal.search_paths = fn.ireject(fn.imap(vim.split(value, ","), fn.trim),
                            function(path) return path == "" end)
                    end, 400),
                }),
                n.rows(
                    { flex = 0, hidden = signal.search_info:map(function(value) return value == "" end) },
                    n.paragraph({
                        lines = signal.search_info,
                        padding = { left = 1, right = 1 },
                        is_focusable = false,
                    })
                ),
                n.gap({
                    flex = 1,
                    hidden = signal.search_results:map(function(value) return #value ~= 0 end),
                }),
                search_tree({
                    search_query = signal.search_query,
                    replace_query = signal.replace_query,
                    data = signal.search_results,
                    origin_winid = renderer:get_origin_winid(),
                    hidden = signal.search_results:map(function(value) return #value == 0 end),
                })
            )
        ))
        renderer:render(body)
    end
end

M.keys = {
    { spectre_keymap.toggle, function() SpectreUI.toggle() end }
}

return M
