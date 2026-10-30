require("nvchad.configs.lspconfig").defaults()

-- rust_analyzer do rustaceanvim quản lý, jdtls do nvim-jdtls quản lý (plugins/rust.lua, plugins/java.lua)
local servers = {
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

-- Odoo: odoo_ls đảm nhiệm, pyright chỉ chạy ở project Python thường
-- (giống .vscode/settings.json của project Odoo: "python.languageServer": "None")
vim.lsp.config("pyright", {
  root_dir = function(bufnr, on_dir)
    local file = vim.api.nvim_buf_get_name(bufnr)
    if vim.fs.root(file, "odools.toml") then
      return
    end
    local root = vim.fs.root(file, {
      "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git",
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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- ruff chỉ lint/format; hover để pyright / odoo_ls
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- read :h vim.lsp.config for changing options of lsp servers
