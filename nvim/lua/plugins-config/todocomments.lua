local status_ok, todocomments = pcall(require, 'todo-comments')
if not status_ok then return end

todocomments.setup {
  signs = false, -- show icons in the signs column
  sign_priority = 8, -- sign priority
  -- keywords recognized as todo comments
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "fix", "error", "ERROR", "BUG", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "todo", alt = { "todo" } },
    HACK = { icon = " ", color = "hack", alt = { "hack" } },
    WARN = { icon = " ", color = "warning", alt = { "warn", "WARNING" } },
    PERF = { icon = " ", color = "hint", alt = { "perf", "optimize", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "info", alt = { "note", "info", "INFO" } },
  },
  merge_keywords = true, -- when true, custom keywords will be merged with the defaults
  -- highlighting of the line containing the todo comment
  -- * before: highlights before the keyword (typically comment characters)
  -- * keyword: highlights of the keyword
  -- * after: highlights after the keyword (todo text)
  highlight = {
    before = "", -- "fg" or "bg" or empty
    keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
    after = "fg", -- "fg" or "bg" or empty
    pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
    comments_only = true, -- uses treesitter to match keywords in comments only
    max_line_len = 200, -- ignore lines longer than this
    exclude = {}, -- list of file types to exclude highlighting
  },
  -- list of named colors where we try to extract the guifg from the
  -- list of hilight groups or use the hex color if hl not found as a fallback
  colors = {
    error = { "#D74E42", "DiagnosticError", "ErrorMsg" },
    warning = { "#E9D16C", "DiagnosticWarning", "WarningMsg" },
    info = {"#98C379", "DiagnosticInfo" },
    hint = {  "#1085FF", "DiagnosticHint" },
    todo = { "#B57EDC" },
    hack = { "#D19A66" },
    default = { "Identifier" },
  },
  search = {
    command = "rg",
    args = {
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
    },
    -- regex that will be used to match keywords.
    -- don't replace the (KEYWORDS) placeholder
    pattern = [[\b(KEYWORDS):]], -- ripgrep regex
    -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
  },
}

