--- The "orgmode.api" module, with additional shims attached for convenience.
---@class M : OrgApi
local M = {}

local org = require("orgmode.api")

---@alias fzo.File OrgApiFile
---@alias fzo.Headline OrgApiHeadline
---@alias fzo.Item fzo.Headline|fzo.File|fzo.Link

--- Get current Org file, if available. Otherwise returns false.
---@return fzo.File|false
function M.get_current()
  local ok, current = pcall(org.current)
  return ok and current
end

setmetatable(M, { __index = org })

return M
