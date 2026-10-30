-- Plugin giao diện và tiện ích, cấu hình giống NvChad v2.5 (nvchad/configs/*) để giữ nguyên cảm giác

require("nvim-web-devicons").setup { override = require "nvchad.icons.devicons" }

-- indent guides
local hooks = require "ibl.hooks"
hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
require("ibl").setup {
  indent = { char = "│", highlight = "IblIndent" },
  scope = { char = "│", highlight = "IblScope" },
}

require("which-key").setup {}

require("gitsigns").setup {
  signs = {
    delete = { text = "󰍵" },
    changedelete = { text = "󱕖" },
  },
}

require("nvim-tree").setup {
  filters = { dotfiles = false },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = { enable = true, update_root = false },
  view = { width = 30, preserve_window_proportions = true },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = { unmerged = "" },
      },
    },
  },
}

require("telescope").setup {
  defaults = {
    prompt_prefix = "   ",
    selection_caret = " ",
    entry_prefix = " ",
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = { prompt_position = "top", preview_width = 0.55 },
      width = 0.87,
      height = 0.80,
    },
    mappings = { n = { ["q"] = require("telescope.actions").close } },
  },
}
-- picker "themes" (<leader>th) và "terms" (<leader>pt) do nvchad/ui cung cấp
for _, ext in ipairs { "themes", "terms" } do
  pcall(require("telescope").load_extension, ext)
end

require("nvim-autopairs").setup {
  fast_wrap = {},
  disable_filetype = { "TelescopePrompt", "vim" },
}

require("nvim-ts-autotag").setup()
