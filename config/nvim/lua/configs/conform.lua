-- Ngôn ngữ không khai báo ở đây (rust, java, toml, typst, tex...) rơi về LSP format
-- qua <leader>fm (lsp_fallback = true trong mappings của NvChad)
local prettier = { "prettier" }

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang-format" },
    python = { "ruff_format" },
    go = { "goimports", "gofumpt" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    css = prettier,
    scss = prettier,
    html = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    markdown = prettier,
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
