-- LSP dùng API gốc của Neovim (vim.lsp.config / vim.lsp.enable); nvim-lspconfig chỉ cung cấp dữ liệu lsp/*.lua.
-- rust_analyzer do rustaceanvim quản lý, jdtls do nvim-jdtls quản lý, roslyn do roslyn.nvim tự bật
-- (không bật qua vim.lsp.enable).
local servers = {
  "lua_ls",
  -- web / frontend
  "ts_ls",
  "eslint",
  "html",
  "cssls",
  "tailwindcss",
  "emmet_language_server",
  "jsonls",
  "yamlls",
  "prismals",
  -- backend
  "gopls",
  "golangci_lint_ls",
  "pyright",
  "ruff",
  "odoo_ls",
  -- khác
  "clangd",
  "taplo",
  "marksman",
}

require("nvchad.lsp").diagnostic_config()

-- Giữ hành vi NvChad: tắt semantic tokens để màu do treesitter / base46 quyết định
vim.lsp.config("*", {
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

-- Cấu hình riêng của từng server nằm ở after/lsp/<tên>.lua: Neovim nạp mọi lsp/<tên>.lua trên
-- runtimepath, after/ nạp sau nên merge lên dữ liệu của nvim-lspconfig. Hai file là định nghĩa
-- trọn vẹn vì nvim-lspconfig không có: after/lsp/roslyn.lua và after/lsp/odoo_ls.lua.

vim.lsp.enable(servers)

-- Mọi chữ cái đều kích hoạt completion (mặc định chỉ ký tự trigger như "."), xem :h lsp-autocompletion
local letters = {}
for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch "." do
  letters[#letters + 1] = c
end

local extended = {}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Completion gốc (thay nvim-cmp): <C-y> chấp nhận, <C-n>/<C-p> chọn, <C-Space> gọi tay
    if client:supports_method "textDocument/completion" then
      if not extended[client.id] then -- mỗi client chỉ mở rộng một lần, dù attach nhiều buffer
        extended[client.id] = true
        local provider = client.server_capabilities.completionProvider
        provider.triggerCharacters = vim.list_extend(provider.triggerCharacters or {}, letters)
      end
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end

    -- ruff chỉ lint / format; hover để pyright / odoo_ls
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end

    -- Màu do colorify của nvchad/ui lo (hex, tailwind); tắt bản gốc để không hiện đôi
    vim.lsp.document_color.enable(false, { bufnr = buf })

    -- Phím tắt như NvChad (gra / grr / grn / gri / grt / K / gO đã có sẵn trong Neovim)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buf = buf, desc = "LSP " .. desc })
    end

    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
    map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
    map("<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List workspace folders")
    map("<leader>D", vim.lsp.buf.type_definition, "Go to type definition")
    map("<leader>ra", require "nvchad.lsp.renamer", "NvRenamer")
  end,
})
