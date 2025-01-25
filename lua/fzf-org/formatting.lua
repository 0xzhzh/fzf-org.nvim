local M = {}

local fzf = require("fzf-org.fzf")
local utils = require("fzf-org.utils")
local links = require("fzf-org.links")

---@param category string
---@param _ fzo.Opts
function M.format_category(category, _)
  local s = string.format("<<%s>>", category)
  local width = 16
  return s .. string.rep(" ", math.floor(width) - utils.strlen(s))
end

---@param file fzo.File
---@param opts fzo.Opts
---@return string entry
function M.file_to_entry(file, opts)
  local link = links.file_to_link(file)
  local category, filename = "", ""

  category = M.format_category(file.category, opts)

  filename = file.filename

  if opts.color_icons then
    category = fzf.utils.ansi_from_hl("Identifier", category)
  end

  return string.format("%s %s %s", link, category, filename)
end

---@param headline fzo.Headline
---@param opts fzo.Opts
---@return string entry
function M.headline_to_entry(headline, opts)
  local link = links.headline_to_link(headline)
  local category, bullet, todo, title, tags = "", "", "", "", ""

  category = M.format_category(headline.file.category, opts)

  if type(opts.bullet_icons) == "table" then
    bullet = opts.bullet_icons[math.min(#opts.bullet_icons, headline.level)]
  end
  if #bullet > 0 then bullet = " " .. bullet end

  if opts.todo_icons == "value" then
    todo = headline.todo_value or string.rep(" ", 6)
  elseif type(opts.todo_icons) == "table" then
    todo = (function()
      local icons = opts.todo_icons --[[@as table]]
      local t = nil --[[@as string|nil]]
      if headline.todo_value then
        t = icons[headline.todo_value]
        if t then return t end
      end
      if headline.todo_type then
        t = icons[headline.todo_type]
        if t then return t end
      end
      if icons.default then return icons.default end

      -- Compute the amount of padding to put in the absence of a TODO icon
      local widest = 1
      for _, v in pairs(icons) do widest = math.max(widest, utils.strlen(v)) end
      return string.rep(" ", widest)
    end)()
  end
  if #todo > 0 then todo = " " .. todo end

  title = " " .. headline.title

  if opts.show_tags and headline.tags and #headline.tags > 0 then
    tags = " :"
    for _, tag in ipairs(headline.tags) do
      tags = tags .. tag .. ":"
    end
  end

  if opts.color_icons ~= false then
    category = fzf.utils.ansi_from_hl("Identifier", category)
    bullet = fzf.utils.ansi_from_hl("Operator", bullet)
    todo = fzf.utils.ansi_from_hl("ErrorMsg", todo)
    tags = fzf.utils.ansi_from_hl("Label", tags)
  end

  return string.format("%s %s%s%s%s%s",
    link,
    category,
    bullet,
    todo,
    title,
    tags)
end

return M
