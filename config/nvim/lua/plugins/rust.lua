return {
  -- tự quản lý rust-analyzer, không bật qua vim.lsp.enable
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false, -- plugin đã tự lazy theo filetype
    init = function()
      vim.g.rustaceanvim = function()
        return require "configs.rust"
      end
    end,
  },

  -- version / feature completion + code action trong Cargo.toml
  {
    "saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    opts = {
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
  },
}
