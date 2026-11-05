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
  "tinymist",
  "texlab",
  "marksman",
}

require("nvchad.lsp").diagnostic_config()

-- Giữ hành vi NvChad: tắt semantic tokens để màu do treesitter / base46 quyết định
vim.lsp.config("*", {
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

vim.lsp.config("lua_ls", {
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
})

local ts_hints = {
  includeInlayParameterNameHints = "literals",
  includeInlayFunctionParameterTypeHints = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

vim.lsp.config("ts_ls", {
  settings = { typescript = { inlayHints = ts_hints }, javascript = { inlayHints = ts_hints } },
})

vim.lsp.config("jsonls", {
  settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" }, -- dùng SchemaStore.nvim thay vì tự fetch
      schemas = require("schemastore").yaml.schemas(),
    },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      analyses = { unusedparams = true, unusedwrite = true, useany = true, shadow = true },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- Roslyn (C#, Razor) cần roslyn-language-server trong PATH: cài bằng mise, xem config/mise/config.toml.
-- Gợi ý inlay hiện khi bật bằng <leader>uh; completion kèm cả kiểu chưa using (như completeUnimported của gopls).
vim.lsp.config("roslyn", {
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
})

-- Odoo: odoo_ls đảm nhiệm, pyright chỉ chạy ở project Python thường
-- (giống .vscode/settings.json của project Odoo: "python.languageServer": "None")
vim.lsp.config("pyright", {
  root_dir = function(bufnr, on_dir)
    local file = vim.api.nvim_buf_get_name(bufnr)
    if vim.fs.root(file, "odools.toml") then
      return
    end
    local root = vim.fs.root(file, {
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    })
    on_dir(root or vim.fs.dirname(file))
  end,
  settings = { pyright = { disableOrganizeImports = true } }, -- để ruff lo import
})

-- OdooLS (https://github.com/odoo/odoo-ls). Binary + typeshed nằm ở ~/.local/share/nvim/odoo,
-- tương đương lsp/odoo_ls.lua của odoo/odoo-neovim nhưng chỉ chạy khi có odools.toml.
vim.lsp.config("odoo_ls", {
  cmd = {
    vim.fn.executable(vim.fn.stdpath "data" .. "/odoo/odoo_ls_server") == 1
        and vim.fn.stdpath "data" .. "/odoo/odoo_ls_server"
      or "odoo_ls_server",
  },
  filetypes = { "python", "xml" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, "odools.toml")
    if root then
      on_dir(root)
    end
  end,
  settings = { Odoo = { selectedProfile = "default" } },
})

vim.lsp.config("tinymist", {
  settings = { formatterMode = "typstyle", exportPdf = "never" },
})

-- vimtex lo việc build/view, texlab chỉ làm completion, diagnostics, format
vim.lsp.config("texlab", {
  settings = {
    texlab = {
      build = { onSave = false },
      chktex = { onOpenAndSave = true },
    },
  },
})

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
