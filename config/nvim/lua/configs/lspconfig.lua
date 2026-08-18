require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls","ts_ls", "gopls", "rust-analyzer", "lua-language-server", "tailwindcss", "clangd", "phpantom", "tinymist", "pyright"}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
