---@diagnostic disable: unused-local
local M = {}

local fzf = require("fzf-org.fzf")
local org = require("fzf-org.org")
local utils = require("fzf-org.utils")
local links = require("fzf-org.links")

---@param p string
---@return string dir
local function dirname(p)
  if not p then return "" end
  return vim.uv.fs_realpath(vim.fs.dirname(p)) or ""
end

--- HACK: check if we are refiling a capture, which will be in a temporary file
--- See: https://github.com/nvim-orgmode/orgmode/issues/872
---@param headline fzo.Headline
---@return boolean
local function is_capture(headline)
  return dirname(headline.file.filename) == dirname(vim.fn.tempname())
end

---@param selected string[]
---@param opts fzo.Opts
function M.refile_headline(selected, opts)
  local src_kind, src = links.resolve_item(opts._origin)
  local dst_kind, dst = links.resolve_item(selected[1] --[[@as fzo.Link]])
  if src_kind ~= "headline" then
    utils.err("could not refile: no headline found at cursor")
    return
  end
  if not dst then
    utils.err("could not refile: no destination found")
    return
  end

  ---@cast src fzo.Headline
  ---@type string
  local src_description = src_kind

  if is_capture(src) then
    local parent = src.parent
    while parent do
      src = parent
      parent = src.parent
    end
    src_description = "capture"
  end

  org.refile({ source = src, destination = dst })

  if dst_kind == "headline" then
    ---@cast dst fzo.Headline
    utils.info(string.format("refiled %s under %s", src_description, dst.title))
  elseif dst_kind == "file" then
    ---@cast dst fzo.File
    utils.info(string.format("refiled %s to %s", src_description, dst.filename))
  end
end

fzf.register_action(M.refile_headline, "org-refile-headline", { header = "refile header", pos = 1 })

---@param selected string[]
---@param opts fzo.Opts
function M.yank_link(selected, opts)
  local _, obj = links.resolve_item(selected[1] --[[@as fzo.Link]])
  if obj then
    local link = obj:get_link()
    vim.schedule(function()
      local reg
      if vim.o.clipboard == "unnamed" then
        reg = [[*]]
      elseif vim.o.clipboard == "unnamedplus" then
        reg = [[+]]
      else
        reg = [["]]
      end
      vim.fn.setreg(reg, link)
      vim.fn.setreg([[0]], link)
      utils.info(string.format("yanked to register %s: %s", reg, link))
    end)
  end
end

fzf.register_action(M.yank_link, "org-yank-link", { header = "yank link" })

setmetatable(M, { __index = fzf.actions })

return M
