-- ~/.config/nvim/init.lua
-- Requires Neovim 0.12+ (uses the built-in vim.pack plugin manager).
if vim.fn.has('nvim-0.12') == 0 then
  vim.api.nvim_echo({ { 'This config requires Neovim 0.12+ (vim.pack). Upgrade Neovim; see README.md for installation options.', 'ErrorMsg' } }, true, {})
  return
end

vim.loader.enable() -- faster Lua module loading
vim.g.mapleader = ' '

require('options')

-- Hook: recompile treesitter parsers whenever nvim-treesitter is updated.
-- Must be defined before the first vim.pack.add() call.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

-- Plugins (installed + loaded by vim.pack; run :lua vim.pack.update() to update)
vim.pack.add({
  { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' }, -- colorscheme
  'https://github.com/nvim-tree/nvim-web-devicons',                    -- icons
  'https://github.com/nvim-tree/nvim-tree.lua',                        -- file tree
  'https://github.com/nvim-lualine/lualine.nvim',                      -- statusline
  'https://github.com/nvim-lua/plenary.nvim',                          -- telescope dependency
  'https://github.com/nvim-telescope/telescope.nvim',                  -- fuzzy finder
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' }, -- syntax highlighting
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim', version = vim.version.range('^8.14.0') }, -- markdown + wrapping tables
  'https://github.com/nvim-mini/mini.pairs',                           -- auto-close brackets
  'https://github.com/gaoDean/autolist.nvim',                          -- markdown list continuation
  'https://github.com/neovim/nvim-lspconfig',                          -- LSP server definitions
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1') }, -- stable completion
})

vim.cmd.colorscheme('rose-pine')
require('mini.pairs').setup()

require('plugins.tree')
require('plugins.lualine')
require('plugins.treesitter')
require('plugins.markdown')
require('plugins.completion')
require('plugins.lsp')
require('keymaps')
