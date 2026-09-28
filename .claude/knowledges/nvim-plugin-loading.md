# nvim plugin load events (zpack over vim.pack)

## Anything with a `FileType` autocmd loads on `BufReadPre`/`BufNewFile`

nvim-treesitter (`plugins/treesitter-config.lua`) and mason-lspconfig
(`plugins/lsp-config.lua`) use `event = { 'BufReadPre', 'BufNewFile' }`.

They used to load on `BufEnter`. zpack replays only the triggering event
after loading a plugin, and for the file passed on the command line
`FileType` has already fired by `BufEnter` — so the plugin's own `FileType`
autocmd (treesitter start, LSP enable) was registered too late. `nvim x.py`
opened with no treesitter, and `nvim x.lua` with no LSP; `:e` afterwards
worked, which hid it. Lua still highlighted because nvim's built-in ftplugin
starts treesitter for Lua itself.

Session restore works because `plugins/sessions-config.lua` sources the session
from a `VimEnter` autocmd with `nested = true`; without `nested`, restored
buffers never fire `FileType` and get neither treesitter nor LSP.

Buffers that never read a file (`nvim -`, `:enew` then `:set ft=…`) don't
trigger the load until a real file is opened.

Headless check (4 s lets servers attach):

```bash
nvim --headless -i NONE x.py +'lua vim.defer_fn(function() local b=vim.api.nvim_get_current_buf(); io.stdout:write(("ts=%s lsp=%d\n"):format(vim.treesitter.highlighter.active[b]~=nil, #vim.lsp.get_clients({bufnr=b}))); vim.cmd("qa!") end, 4000)'
```

Don't test the "no args, then `:e`" case with `+'e file'` — session autoload
replaces the buffer at `VimEnter`. Defer the `:e` past startup instead.

## Don't register a treesitter language that isn't in the registry

`vim.treesitter.language.register('jsonc', 'json')` made every json buffer
resolve to `jsonc`, which nvim-treesitter's registry doesn't offer, so the
`FileType` handler cached json as "no parser" and skipped it forever — even
with `json.so` installed. Check `require('nvim-treesitter').get_available()`
before adding a mapping.

## lualine theme

`plugins/lualine-config.lua` sets `theme = 'oxocarbon'` directly (oxocarbon.nvim
ships `lua/lualine/themes/oxocarbon.lua`). A `nil` theme silently falls back to
lualine's `auto`.
