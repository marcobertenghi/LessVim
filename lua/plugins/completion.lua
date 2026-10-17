-- Blink v1: LSP-only completion with the native Rust fuzzy matcher.
require('blink.cmp').setup({
  keymap = {
    -- Only completion keys; preserve Tab, Enter, and the Ctrl-b code block map.
    preset = 'none',
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<C-y>'] = { 'select_and_accept', 'fallback' },
    ['<C-e>'] = { 'hide', 'fallback' },
  },
  sources = {
    default = { 'lsp' },
    providers = { lsp = { fallbacks = {} } },
  },
  completion = {
    trigger = { show_on_backspace_in_keyword = true },
    list = { selection = { preselect = false, auto_insert = false } },
    -- mini.pairs already handles brackets; avoid a second bracket engine.
    accept = { auto_brackets = { enabled = false } },
  },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  cmdline = { enabled = false },
  term = { enabled = false },
})
