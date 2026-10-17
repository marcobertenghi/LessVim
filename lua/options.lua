-- General editor options

vim.opt.number = true         -- absolute line number on current line
vim.opt.relativenumber = true -- relative line numbers elsewhere
vim.opt.linebreak = true      -- wrap at word boundaries
vim.opt.termguicolors = true  -- 24-bit colour
vim.opt.mouse = 'a'           -- mouse support everywhere
vim.opt.swapfile = false      -- no swap files
vim.opt.scrolloff = 7         -- keep context around the cursor
vim.opt.fileformat = 'unix'

-- Tabs and indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- spaces, not tabs (PEP 8)
vim.opt.autoindent = true
