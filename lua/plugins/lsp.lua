-- LSP: basedpyright (types, completion, navigation) + ruff (lint, format)
-- Server binaries must be on PATH: basedpyright-langserver and ruff (see README).
-- Server settings live in lsp/basedpyright.lua and lsp/ruff.lua.

-- Show diagnostics inline (off by default since Neovim 0.11)
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
})

-- Native manual completion options; automatic completion is handled by Blink.
vim.opt.completeopt = { 'menuone', 'noselect', 'popup', 'fuzzy' }

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- basedpyright owns hover docs (K); ruff only lints and formats
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- Run one of ruff's "source" code actions and apply the resulting edit.
--
-- vim.lsp.buf.code_action() is asynchronous, so calling it from BufWritePre
-- races the write and usually loses. Instead we issue the request
-- synchronously against the ruff client and apply the workspace edit
-- ourselves, which is guaranteed to land before the buffer hits disk.
--
-- Useful kinds: 'source.organizeImports.ruff' (isort), 'source.fixAll.ruff'
-- (every safe autofix -- note this also *deletes* imports you aren't using
-- yet, which is why it isn't wired into save below).
local function ruff_source_action(bufnr, kind, timeout_ms)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'ruff' })[1]
  if not client then return end

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    -- source.* actions apply document-wide; the range is required but ignored
    range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 0 } },
    context = { only = { kind }, diagnostics = {} },
  }

  local res = client:request_sync('textDocument/codeAction', params, timeout_ms or 1000, bufnr)
  if not res or res.err or not res.result then return end

  for _, action in ipairs(res.result) do
    -- Some servers return the action without its edit; resolve it first.
    if not action.edit and action.data then
      local resolved = client:request_sync('codeAction/resolve', action, timeout_ms or 1000, bufnr)
      if resolved and not resolved.err and resolved.result then
        action = resolved.result
      end
    end
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

-- On save: sort imports (fixes ruff's "Import block is un-sorted or
-- un-formatted", rule I001), then format. Order matters -- the formatter
-- tidies up whatever the import sort produced.
-- Requires the isort rules to be selected in the project's ruff config, e.g.
--   [tool.ruff.lint]
--   select = ["E", "F", "I"]
-- Comment out this autocmd to disable both.
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.py',
  callback = function(args)
    ruff_source_action(args.buf, 'source.organizeImports.ruff')
    vim.lsp.buf.format({
      bufnr = args.buf,
      filter = function(c) return c.name == 'ruff' end,
    })
  end,
})

vim.lsp.enable({ 'basedpyright', 'ruff' })
