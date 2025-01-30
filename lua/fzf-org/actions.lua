---@diagnostic disable: unused-local
local M = {}

local fzf = require("fzf-org.fzf")
local org = require("fzf-org.org")
local utils = require("fzf-org.utils")
local links = require("fzf-org.links")

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

  if opts._from_capture then
    -- Mirror the behavior of nvim-orgmode's capture.refile_to_destination
    -- (see discussion: https://github.com/nvim-orgmode/orgmode/issues/872)
    src = src.file.headlines[1]
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
