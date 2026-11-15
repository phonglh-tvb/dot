-- Merge lên lsp/lua_ls.lua của nvim-lspconfig. Phần dùng chung cho mọi server ở lua/configs/lspconfig.lua.
return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        library = {
          vim.env.VIMRUNTIME .. "/lua",
          vim.fn.stdpath "data" .. "/site/pack/core/opt/ui/nvchad_types",
          "${3rd}/luv/library",
        },
      },
    },
  },
}
