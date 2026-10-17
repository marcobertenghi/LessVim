-- nvim-tree: file explorer

-- Disable netrw (recommended by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
  sort = { sorter = 'case_sensitive' },
  view = { width = 30 },
  renderer = { group_empty = true },
  filters = { dotfiles = false },
})

-- nvim-tree handles directory arguments itself. Use <leader>e otherwise.
