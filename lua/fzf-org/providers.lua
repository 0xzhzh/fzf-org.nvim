local M = {}

local fzf = require("fzf-org.fzf")
local org = require("fzf-org.org")
local fmt = require("fzf-org.formatting")
local links = require("fzf-org.links")
local utils = require("fzf-org.utils")
local config = require("fzf-org.config")

---@param opts fzo.Opts|nil
function M.orgmode(opts)
  if opts and type(opts.where) == "table" then
    -- Serialize all data structures that normalize_opts might not like
    for i, item in ipairs(opts.where --[[@as fzo.Item[]]) do
      opts.where[i] = links.serialize(item)
    end
  end

  opts = fzf.config.normalize_opts(opts or {}, config.defaults.orgmode)
  ---@cast opts fzo.Opts|nil
  if not opts then return end

  -- Certain values of "where" imply certain requirements on "whence" (where we search from).
  -- Propagate those implied requirements here.
  if type(opts.where) == "string" then
    if opts.where == "%" then
      opts.whence = "file"
    elseif opts.where == "." then
      opts.whence = "headline"
    end
  end

  if opts._origin == nil then
    -- Save original calling context here, because get_current() does not work
    -- inside the fzf_exec() context.
    local current = org.get_current()
    if current then
      if opts.whence == "file" then
        -- The caller asked for a file, and we're in one. No need to refine the
        -- origin any further.
        opts._origin = links.file_to_link(current)
      else
        local headline = current:get_closest_headline()
        if headline then
          opts._origin = links.headline_to_link(headline)
        elseif opts.whence == "headline" then
          utils.err("No current Org headline")
          return
        else -- opts.whence == false
          -- We could not find a headline in this Org file, but the caller
          -- did not ask for any particular context, so we can move on.
          opts._origin = links.file_to_link(current)
        end
      end
    else -- did not originate from Org file
      if opts.whence then
        utils.err("No current Org " .. opts.whence)
        return
      end
    end
  end

  opts = fzf.set_header(opts, opts.headers or { "actions" })

  local function org_contents(cb)
    ---@type fzo.Item[]
    local where
    if opts.where == "*" then
      -- Load all files
      where = org.load()
    elseif opts.where == "%" or opts.where == "." then
      -- Start from origin, whether it is a file or headline
      assert(opts._origin) -- the whence check should have ruled out _origin == false
      where = { opts._origin --[[@as fzo.Link]] }
    elseif type(opts.where) == "table" then
      -- Assume it is a list of items
      where = opts.where --[[@as fzo.Item[] ]]
    elseif type(opts.where) == "string" then
      utils.err("Invalid value for option 'where': " .. opts.where)
      return
    else
      utils.err("Invalid type for option 'where': " .. type(opts.where))
      return
    end
    for _, item in ipairs(where) do
      local kind, obj = links.resolve_item(item)
      if opts.what == "headline" and (kind == "headline" or kind == "file") then
        ---@cast obj fzo.Headline|fzo.File
        for _, headline in ipairs(obj.headlines) do
          cb(fmt.headline_to_entry(headline, opts))
        end
      elseif opts.what == "file" and kind == "file" then
        ---@cast obj fzo.File
        cb(fmt.file_to_entry(obj, opts))
      else
      end
    end
    cb()
  end

  fzf.fzf_exec(org_contents, opts)
end

return M
