--- The "fzf-lua" module, with additional shims attached for convenience.
---@module "fzf-lua"
local M = {}

local fzf = require("fzf-lua")

M.previewers = require("fzf-lua.previewer.builtin")
M.config = require("fzf-lua.config")

M.set_header = fzf.core.set_header

---@param action function
---@param helpstr string
---@param opts {header: string|nil, pos: number|nil}
function M.register_action(action, helpstr, opts)
  fzf.config.set_action_helpstr(action, helpstr)
  if opts and opts.header then
    fzf.core.ACTION_DEFINITIONS[action] = { opts.header, pos = opts.pos }
  end
end

setmetatable(M, { __index = fzf })

return M
