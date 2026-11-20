-- Markdown, và crates.nvim cho Cargo.toml

-- Markdown: render ngay trong buffer
require("render-markdown").setup {
  file_types = { "markdown" },
  completions = { lsp = { enabled = true } },
}

-- Markdown: preview trên trình duyệt (KaTeX, mermaid); bước build nằm trong hook PackChanged (plugins.lua)
vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_auto_close = 0

-- Version / feature completion và code action trong Cargo.toml
require("crates").setup {
  lsp = { enabled = true, actions = true, completion = true, hover = true },
}
