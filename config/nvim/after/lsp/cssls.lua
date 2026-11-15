-- Merge lên lsp/cssls.lua của nvim-lspconfig. Phần dùng chung cho mọi server ở lua/configs/lspconfig.lua.
-- Bỏ cảnh báo "Do not use empty rulesets": khối rỗng là chuyện thường khi đang viết dở hay dựng khung class.
return {
  settings = {
    css = { lint = { emptyRules = "ignore" } },
    scss = { lint = { emptyRules = "ignore" } },
    less = { lint = { emptyRules = "ignore" } },
  },
}
