-- Markdown note-taking: pretty rendering + smart list continuation

require('render-markdown').setup({})

require('autolist').setup({
  ft = { 'markdown' },
})

local M = {}

local function in_code_fence()
  local ok, node = pcall(function()
    vim.treesitter.get_parser(0, 'markdown'):parse()
    -- A blank new line has column zero, which autolist's fence check mishandles.
    return vim.treesitter.get_node({ lang = 'markdown', ignore_injections = true })
  end)
  while ok and node do
    if node:type() == 'fenced_code_block' then return true end
    node = node:parent()
  end
  return false
end

-- Autolist always indents colon-created lists. Keep lists after ordinary
-- paragraphs aligned with the paragraph; existing list items can still nest.
function M.new_bullet()
  if in_code_fence() then return end
  local previous = vim.fn.getline(vim.fn.line('.') - 1)
  local before = vim.api.nvim_get_current_line()
  require('autolist').new_bullet()

  if not previous:match(':%s*$') then return end
  local config = require('autolist.config')
  local utils = require('autolist.utils')
  if utils.is_list(previous, config.lists[vim.bo.filetype]) then return end

  local current = vim.api.nvim_get_current_line()
  local prefix = config.tab .. previous:match('^%s*') .. config.colon.preferred .. ' '
  if current ~= before and current:sub(1, #prefix) == prefix then
    -- Only adjust a bullet actually added by autolist. In code fences it
    -- leaves the line untouched, so code indentation is preserved.
    utils.set_current_line(current:sub(#config.tab + 1))
  end
end

return M
