-- nvim-lspconfig không có lsp/roslyn.lua (nó chỉ có roslyn_ls, không hỗ trợ Razor), nên file này là
-- toàn bộ định nghĩa; roslyn.nvim đọc nó và tự bật server, không qua vim.lsp.enable.
-- Cần roslyn-language-server trong PATH: cài bằng mise, xem config/mise/config.toml.
-- Gợi ý inlay hiện khi bật bằng <leader>uh; completion kèm cả kiểu chưa using (như completeUnimported của gopls).
return {
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
    },
    ["csharp|completion"] = {
      dotnet_show_completion_items_from_unimported_namespaces = true,
    },
  },
}
