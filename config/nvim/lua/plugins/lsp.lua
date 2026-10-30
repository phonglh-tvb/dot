-- Tooling dùng chung cho FE / backend
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsClean" },
    opts = function()
      return { ensure_installed = require "configs.tools", start_delay = 3000 }
    end,
  },

  -- schema cho package.json, tsconfig, docker-compose, github workflow...
  { "b0o/SchemaStore.nvim", lazy = true },

  -- danh sách diagnostics / references / symbols
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>qd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble diagnostics (workspace)" },
      { "<leader>qb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble diagnostics (buffer)" },
      { "<leader>qs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Trouble symbols" },
      { "<leader>qr", "<cmd>Trouble lsp_references toggle focus=false<cr>", desc = "Trouble LSP references" },
      { "<leader>ql", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble quickfix" },
    },
  },

  -- tự đóng / đổi tên tag (html, tsx, jsx, xml của Odoo)
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },
}
