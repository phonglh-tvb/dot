-- Merge lên lsp/lua_ls.lua của nvim-lspconfig. Phần dùng chung cho mọi server ở lua/configs/lspconfig.lua.
return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        -- Mặc định "Ask": thấy chữ như love., ngx., require "luassert" là hiện hộp thoại hỏi có cấu hình môi
        -- trường cho thư viện đó không. Thư viện cần thì đã khai báo ở library bên dưới.
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME .. "/lua",
          vim.fn.stdpath "data" .. "/site/pack/core/opt/ui/nvchad_types",
          "${3rd}/luv/library",
        },
      },
    },
  },
}
