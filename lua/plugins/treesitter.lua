-- nvim-treesitter (main branch): syntax highlighting and native folding
-- Parsers are compiled locally; requires the tree-sitter CLI and a C compiler
-- (see README). Run :TSUpdate after Neovim updates if highlighting breaks.

local parsers = {
  'python',
  'bash',
  'markdown',
  'markdown_inline',
  'html',
  'javascript',
  'yaml',
  'lua',
  'json',
  'toml',
  'ini',
  'xml',
  'hcl',
  'terraform',
  'dockerfile',
  'nginx',
}

require('nvim-treesitter').install(parsers)

-- Default for new buffers/windows; Neovim remembers later fold choices itself.
vim.opt.foldlevel = 99

-- Folds are window-local, so also configure them when displaying another buffer.
-- Only enable structural folding when the language supplies a folds query.
local foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
  group = vim.api.nvim_create_augroup('ConfigTreesitter', { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
    if ev.buf ~= vim.api.nvim_get_current_buf() or vim.wo.diff then return end

    local ok, parser = pcall(vim.treesitter.get_parser, ev.buf)
    local has_query, query = false, nil
    if ok and parser then
      has_query, query = pcall(vim.treesitter.query.get, parser:lang(), 'folds')
    end
    if has_query and query then
      if vim.wo.foldmethod ~= 'expr' then vim.wo.foldmethod = 'expr' end
      if vim.wo.foldexpr ~= foldexpr then vim.wo.foldexpr = foldexpr end
    elseif vim.wo.foldexpr == foldexpr then
      -- Do not carry structural folding into unsupported filetypes.
      vim.wo.foldmethod = 'manual'
      vim.wo.foldexpr = '0'
    end
  end,
})
