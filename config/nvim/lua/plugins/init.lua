return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/SchemaStore.nvim" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "luadoc", "vimdoc", "printf",
        -- web / frontend
        "html", "css", "scss", "javascript", "typescript", "tsx", "json", "yaml", "toml", "prisma",
        -- backend
        "python", "go", "gomod", "gosum", "gowork", "gotmpl", "rust", "java", "c", "php",
        -- Odoo: view / QWeb là xml
        "xml",
        -- tài liệu
        "markdown", "markdown_inline", "latex", "bibtex", "typst",
        -- khác
        "bash", "dockerfile", "sql", "regex", "diff", "gitcommit", "git_rebase", "gitignore", "ini", "make",
      },
    },
  },
}
