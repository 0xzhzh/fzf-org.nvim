local M = {}

local fzf = require("fzf-org.fzf")
local links = require("fzf-org.links")
local actions = require("fzf-org.actions")

---@class fzo.Opts
---@field where         fzo.Where|fzo.Item[]|nil      where we should search (default: "*")
---@field what          "headline"|"file"|nil         what we are searching for (default: "headline")
---@field whence        "headline"|"file"|false|nil   where we should have started from (default: false)
---@field color_icons   boolean|nil                   colorize entries (default: true)
---@field bullet_icons  fzo.BulletIcons|nil           how to display bullets (default: icons)
---@field todo_icons    fzo.TodoIcons|nil             how to display TODO (default: icons)
---@field show_tags     boolean|nil                   whether to display tags
---@field _origin       fzo.Link|false|nil            where we started from
---
---@field previewer string|table|nil
---@field fzf_opts  table<string, string|boolean>|nil
---@field prompt    string|nil
---@field actions   table<string, table|function>|nil
---@field headers   string[]|nil

---@alias fzo.Where
---| "*" # all org files
---| "%" # current org file (implies whence = "file")
---| "." # current org headline (implies whence = "headline")

---@alias fzo.BulletIcons
---| string[] # custom icons (e.g., { "*", "**", "***" })
---| false    # don't show bullets

---@alias fzo.TodoIcons
---| { TODO: string, DONE: string, default: string|nil }  # value/type to symbol mapping
---| "value"  # just show the TODO value
---| false    # don't show TODO symbols

---@type fzo.BulletIcons
M.bullet_icons = { "◉", "○", "✸", "✿" }

---@type fzo.TodoIcons
M.todo_icons = {
  TODO = "➔",
  DONE = "✓",
  PROGRESS = "…",
  INPROGRESS = "…",
  default = " ",
}

M.refile_actions = {
  ["default"] = actions.refile_headline,
}

M.defaults = {}

---@type fzo.Opts
M.defaults.orgmode = {
  where        = "*",
  what         = "headline",
  whence       = false,
  color_icons  = true,
  bullet_icons = M.bullet_icons,
  todo_icons   = M.todo_icons,
  show_tags    = true,

  previewer    = "builtin",
  fzf_opts     = links.fzf_opts,
  prompt       = "Orgmode ❯ ",
  headers      = { "actions" },

  _actions     = function() return fzf.config.globals.actions.files end,
  actions      = {
    ["ctrl-y"] = { actions.yank_link, actions.resume },
  },
}

---@type fzo.Opts
M.defaults.all_headlines = {}

---@type fzo.Opts
M.defaults.files = {
  where  = "*",
  what   = "file",
  prompt = "Org files ❯ ",
}

---@type fzo.Opts
M.defaults.headlines = {
  whence = "file",
  where  = "%",
  what   = "headline",
  prompt = "Org headlines ❯ ",
}

---@type fzo.Opts
M.defaults.subheadlines = {
  whence = "file",
  where  = ".",
  what   = "headline",
  prompt = "Org headlines ❯ ",
}

---@type fzo.Opts
M.defaults.refile = {
  whence  = "headline",
  where   = "*",
  what    = "headline",
  prompt  = "Refile to ❯ ",
  actions = M.refile_actions,
}

---@type fzo.Opts
M.defaults.refile_to_file = {
  whence  = "headline",
  where   = "*",
  what    = "file",
  prompt  = "Refile to ❯ ",
  actions = M.refile_actions,
}

---@type fzo.Opts
M.defaults.refile_to_headline = {
  whence  = "headline",
  where   = "*",
  what    = "headline",
  prompt  = "Refile to ❯ ",
  actions = M.refile_actions,
}

return M
