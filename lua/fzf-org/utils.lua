local M = {}

function M.info(msg)
  vim.notify(msg, vim.log.levels.INFO)
end

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN)
end

function M.err(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end

function M.strlen(s)
  return vim.api.nvim_strwidth(s)
end

return M
