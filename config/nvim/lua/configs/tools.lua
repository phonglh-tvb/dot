-- Tên package Mason; mason-tool-installer tự cài những gói còn thiếu (xem plugins/lsp.lua)
return {
  -- LSP: web / frontend
  "typescript-language-server",
  "eslint-lsp",
  "html-lsp",
  "css-lsp",
  "tailwindcss-language-server",
  "emmet-language-server",
  "json-lsp",
  "yaml-language-server",
  "prisma-language-server",

  -- LSP: backend
  "gopls",
  "golangci-lint-langserver",
  "pyright",
  "ruff",
  "rust-analyzer",
  "jdtls",

  -- LSP: khác
  "lua-language-server",
  "taplo",
  "marksman",
  "texlab",
  "tinymist",

  -- Formatter / linter
  "stylua",
  "prettier",
  "clang-format",
  "gofumpt",
  "goimports",
  "golangci-lint",

  -- Debug adapter
  "codelldb",
  "delve",
  "debugpy",
  "js-debug-adapter",
  "java-debug-adapter",
  "java-test",

  "tree-sitter-cli",
}
