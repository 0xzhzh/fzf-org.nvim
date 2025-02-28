<div align="center">

# (fzf :heart: lua) :handshake: (:unicorn: :dancers:)

**Use [fzf-lua][fzf-lua] to browse [nvim-orgmode][nvim-orgmode]**

</div>

[fzf-lua]: https://github.com/ibhagwan/fzf-lua
[nvim-orgmode]: https://github.com/nvim-orgmode/orgmode

> [!IMPORTANT]
> This plugin is currently alpha-quality software and may have some rough edges.
> If you encounter any, please [file an issue](https://github.com/0xzhzh/fzf-org.nvim/issues/new).

## Quickstart

### Requirements

- [fzf-lua][fzf-lua]
- [nvim-orgmode][nvim-orgmode]

Those plugins each have their own requirements; see their respective READMEs for details.

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "0xzhzh/fzf-org.nvim",
  lazy = false, -- lazy loading is handled internally
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-orgmode/orgmode",
  },
  keys = {
    -- example keybindings
    { "<leader>og", function() require("fzf-org").orgmode() end, desc = "org-browse" },
    { "<leader>of", function() require("fzf-org").files() end, desc = "org-files" },
    { "<leader>or", function() require("fzf-org").refile_to_file() end, desc = "org-refile" },
  },
  config = function()
    require("fzf-org").setup { ... } -- see below
  end,
}
```

## Usage

This plugin provides the following functions (where `fzo` is `require("fzf-org")`):

```lua
fzo.all_headlines()       -- Browse all org headlines
fzo.files()               -- Browse all org files
fzo.headlines()           -- Browse org headlines in current file
fzo.subheadlines()        -- Browse org headlines under current headline/file
fzo.refile()              -- Refile to headline
fzo.refile_to_file()      -- Refile to org file
fzo.refile_to_headline()  -- Refile to headline in current file
```

> [!NOTE]
> All of these functions are implemented by passing different options to `fzo.orgmode()`,
> whose default behavior (called without any options) is the same as `fzo.all_headlines()`.

## Configuration

> [!IMPORTANT]
> The structure and default values of these options may experience breaking changes
> while this plugin undergoes development.

### Options

Default options (do not copy and paste these directly):

```lua
{
  -- Default options for fzo.orgmode() (all other options inherit from this)
  orgmode = {
    whence       = false,       -- where we should have started from; false means don't care
    where        = "*",         -- where to search (options: "*" (all org files), "%" (current file), "." (current headline))
    what         = "headline",  -- what to search for

    color_icons  = true,                    -- whether to colorize entries
    bullet_icons = { "◉", "○", "✸", "✿" },  -- how to display bullets
    todo_icons   = {                        -- how to display TODO
      default = "   ",
      TODO = "[ ]",
      NEXT = "[➔]",
      WAITING = "[…]",
      PROGRESS = "[~]",
      INPROGRESS = "[~]",
      DONE = "[✓]",
      ABANDONED = "[⨯]",
    },
    show_tags    = true,                    -- whether to display tags

    -- Other fzf-lua options (see its documentation)
    prompt       = "Orgmode ❯ ",
    headers      = { "actions" },
    actions      = {
      -- Also inherits from fzf.actions.files, e.g., file_edit, file_split, etc.
      ["ctrl-y"] = { actions.yank_link, actions.resume },
    },
  },

  -- Function-specific options; these inherit from orgmode options (above)

  -- fzo.all_headlines()
  all_headlines = {
    -- Same default behavior as fzo.orgmode().
    --
    -- You can add options here to configure the behavior of fzo.all_headlines()
    -- without affecting other functions' inherited options.
  },

  -- fzo.files()
  files = {
    where  = "*",
    what   = "file",
    prompt = "Org files ❯ ",
  },

  -- fzo.headlines()
  headlines = {
    whence = "file",
    where  = "%",
    what   = "headline",
    prompt = "Org headlines ❯ ",
  },

  -- fzo.subheadlines()
  subheadlines = {
    whence = "file",
    where  = ".",
    what   = "headline",
    prompt = "Org headlines ❯ ",
  },

  -- fzo.refile()
  refile = {
    whence  = "headline",
    where   = "*",
    what    = "headline",
    prompt  = "Refile to ❯ ",
    actions = {
      ["default"] = actions.refile_headline,
    },
  }

  -- fzo.refile_to_file()
  refile_to_file = {
    whence  = "headline",
    where   = "*",
    what    = "file",
    prompt  = "Refile to ❯ ",
    actions = {
      ["default"] = actions.refile_headline,
    },
  },

  -- fzo.refile_to_headline()
  refile_to_headline = {
    whence  = "headline",
    where   = "*",
    what    = "headline",
    prompt  = "Refile to ❯ ",
    actions = {
      ["default"] = actions.refile_headline,
    },
  },
}
```

where the `actions` variable is `require("fzf-org.actions")`.

### Actions

This plugin defines the following actions:

```lua
actions.yank_link       -- copy the org link to the clipboard, using the
actions.refile_headline -- refile to the selected file/headline (requires whence = "headline")
```

## Advanced

All the functions are actually implemented via `fzo.orgmode()`, the base provider,
using different specializations of its options.

You can override these options on a per-call basis, e.g.,

```lua
-- This behaves like fzo.files(), except with a different prompt:
fzo.orgmode({
  where  = "*",
  what   = "file",
  prompt = "🔍 ",
})
```

If you would like to contribute, please see [DEVELOPMENT.org](DEVELOPMENT.org).
