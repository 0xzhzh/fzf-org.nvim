local M = {}

local org = require("fzf-org.org")

--- How Org files and headlines are encoded in FZF entries (which are strings).
---
--- Org files are encoded as "<path>::@<etc>", while headlines are encoded as
--- "<path>:<line>:@<etc>", where <path> is the location of the Org file on the
--- file system, <line> is the line number of the headline in the Org file, and
--- <etc> is formatted text displayed in the FZF interface for the user to see.
---
--- This format allows us to reuse FZF's builtin previewer and actions.
---@class fzo.Link : string

--- Options to only display text after the ":@" in the FZF selection interface.
---@type table<string, string>
M.fzf_opts = {
  ["--delimiter"] = ":@",
  ["--with-nth"] = "2..",
}

---@param item fzo.Item|nil
---@return "headline"|"file"|false
function M.classify_item(item)
  if not item then return false end
  if type(item) == "string" then
    return ({ M.parse_link(item) })[1]
  end

  assert(type(item) == "table")
  if item.title then
    -- Only headlines have titles
    return "headline"
  elseif item.category then
    -- Only files have categories
    return "file"
  end
  return false
end

---@param file fzo.File
---@return fzo.Link
function M.file_to_link(file)
  return string.format("%s::@", file.filename) --[[@as fzo.Link]]
end

---@param headline fzo.Headline
---@return fzo.Link
function M.headline_to_link(headline)
  return string.format("%s:%d:@", headline.file.filename, headline.position.start_line) --[[@as fzo.Link]]
end

---@param item fzo.Item
---@return fzo.Link link
function M.serialize(item)
  if type(item) == "string" then return item end -- already a link
  local kind = M.classify_item(item)
  if kind == "headline" then
    return M.headline_to_link(item --[[@as fzo.Headline]])
  elseif kind == "file" then
    return M.file_to_link(item --[[@as fzo.File]])
  else
    error("Could not serialize item: " .. vim.inspect(item))
  end
end

---@param link fzo.Link
---@return "headline"|"file"|false kind
---@return string|nil path
---@return number|nil line
function M.parse_link(link)
  local path, line = string.match(link, "^(.-):(%d-):@.*")
  line = tonumber(line)
  if not path then
    return false
  elseif not line then
    return "file", path
  else
    return "headline", path, line
  end
end

---@param item fzo.Item|nil
---@return "headline"|"file"|false kind
---@return fzo.Headline|fzo.File|nil obj
function M.resolve_item(item)
  if type(item) == "table" then
    local kind = M.classify_item(item)
    return kind, kind and (item --[[@as fzo.Headline|fzo.File]]) or nil
  end
  assert(type(item) == "string")
  local kind, path, line = M.parse_link(item)
  if kind == "headline" then
    assert(path and line)
    local ok, file = pcall(org.load, path)
    if not ok then return false end
    local headline = file:get_closest_headline({ line, 1 })
    if not headline then return false end
    return kind, headline
  elseif kind == "file" then
    assert(path)
    local ok, file = pcall(org.load, path)
    if not ok then return false end
    return kind, file
  end
  return false
end

--- Parse an entry_str into an org file or headline.
---@param entry_str string
---@return fzo.File|fzo.Headline|nil file_or_headline
---@return "file"|"headline"|nil kind
function M.entry_to_file_or_headline(entry_str)
  -- TODO: fix this
  local info = M.previewer.parse_entry(nil, entry_str)
  local ok, file = pcall(org.load, info.path)
  if ok then
    if info.kind == "file" then
      return file, file and "file"
    elseif info.kind == "headline" then
      local headline = file:get_closest_headline({ line = info.line })
      return headline, headline and "headline"
    end
  else
    return nil, nil
  end
end

return M
