local M = {}

local setup_opts

do
  local fzf_functions = {
    "orgmode",
    "all_headlines",
    "files",
    "headlines",
    "subheadlines",
    "refile_to_file",
    "refile_to_headline",
    "refile_to_subheadline",
  }
  -- Lazy load fzf functions
  for _, fn in ipairs(fzf_functions) do
    M[fn] = function(call_opts)
      local default_opts = require("fzf-org.config").defaults[fn]
      assert(default_opts)

      local fn_setup_opts = setup_opts[fn] or {}
      call_opts = call_opts or {}

      local actions = vim.tbl_extend("force",
        default_opts.actions or {},
        fn_setup_opts.actions or {},
        call_opts.actions or {})

      require("fzf-org.providers").orgmode(vim.tbl_extend("force",
        default_opts,
        fn_setup_opts,
        call_opts,
        { actions = actions }))
    end
  end
end

function M.setup(opts)
  setup_opts = opts or {}
end

return M
