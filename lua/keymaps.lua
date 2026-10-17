-- General custom keymaps. Blink completion keys live in plugins/completion.lua.
-- Neovim 0.11+ ships useful LSP defaults out of the box:
--   K = hover docs, grn = rename, grr = references, gra = code action,
--   gri = implementation, gO = document symbols, [d / ]d = prev/next diagnostic,
--   ]b / [b = next/prev buffer, <C-x><C-o> = manual native LSP completion.
-- Code navigation (built in, no mappings needed):
--   <C-]> = jump to definition, <C-t> = jump back, <C-o>/<C-i> = jumplist
--   back/forward, <C-^> = toggle between the two most recent files.

local map = vim.keymap.set

-- Go to definition via LSP (upgrade over stock gd, which is file-local only)
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })

-- Swiss German keyboard: ö/ä sit where US layouts have ;/' (right of L).
-- Use them as the [ and ] prefixes, so öd/äd = prev/next diagnostic,
-- öb/äb = prev/next buffer, etc. -- no Option key needed.
map({ 'n', 'x', 'o' }, 'ö', '[', { remap = true, desc = '[ prefix' })
map({ 'n', 'x', 'o' }, 'ä', ']', { remap = true, desc = '] prefix' })

-- File tree
map('n', '<Leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })

-- Telescope
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Review search results: Telescope Ctrl-q sends matches to quickfix.
-- Native ]q/[q (also äq/öq) already move to the next/previous entry.
map('n', '<leader>qo', '<cmd>copen<CR>', { desc = 'Open quickfix review list' })
map('n', '<leader>qc', '<cmd>cclose<CR>', { desc = 'Close quickfix review list' })
map('n', '<leader>qh', builtin.quickfixhistory, { desc = 'Browse quickfix history' })

-- Markdown lists (autolist) -- buffer-local, markdown only.
--
-- These used to be global. autolist is only configured for markdown
-- (plugins/markdown.lua), so in every other filetype AutolistTab found no
-- list and fell back to `normal! a<Tab>`. `a` appends *after* the character
-- under the cursor, so on a non-empty line the indent landed one column too
-- far right -- and since softtabstop snaps to the next tab stop rather than
-- inserting a fixed width, that off-by-one produced 3 spaces instead of 4.
-- Scoping the mappings to markdown restores stock <Tab> everywhere else.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args)
    local opts = { buffer = args.buf }
    map('i', '<CR>', '<CR><cmd>lua require("plugins.markdown").new_bullet()<CR>', opts)
    map('i', '<tab>', '<cmd>AutolistTab<cr>', opts)
    map('i', '<s-tab>', '<cmd>AutolistShiftTab<cr>', opts)
  end,
})

-- Insert a fenced code block
map('i', '<C-b>', '```<CR>```<ESC>kA', { desc = 'Insert code block' })
