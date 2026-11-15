-- Odoo: odoo_ls đảm nhiệm, pyright chỉ chạy ở project Python thường
-- (giống .vscode/settings.json của project Odoo: "python.languageServer": "None")
return {
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
}
