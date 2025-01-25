local M = {}

local fzf = require("fzf-org.fzf")
local org = require("fzf-org.org")
local utils = require("fzf-org.utils")
local links = require("fzf-org.links")

--- This will be set to providers.orgmode by init.lua to avoid circularity
M._restart = nil

---@param selected string[]
---@param opts fzo.Opts
function M.refile_headline(selected, opts)
  local src_kind, src = links.resolve_item(opts._origin)
  local dst_kind, dst = links.resolve_item(selected[1] --[[@as fzo.Link]])
  if src_kind == "headline" and dst then
    org.refile({ source = src --[[@as fzo.Headline]], destination = dst })
    if dst_kind == "headline" then
      ---@cast dst fzo.Headline
      utils.info(string.format("refiled under %s", dst.title))
    elseif dst_kind == "file" then
      ---@cast dst fzo.File
      utils.info(string.format("refiled to %s", dst.filename))
    end
  end
end

fzf.register_action(M.refile_headline, "org-refile-headline", { header = "refile header", pos = 1 })

---@param selected string[]
---@param _opts fzo.Opts
function M.yank_link(selected, _opts)
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
