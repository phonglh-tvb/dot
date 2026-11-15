-- OdooLS (https://github.com/odoo/odoo-ls). nvim-lspconfig không có lsp/odoo_ls.lua nên file này là
-- toàn bộ định nghĩa, tương đương lsp/odoo_ls.lua của odoo/odoo-neovim nhưng chỉ chạy khi có odools.toml.
-- Binary + typeshed nằm ở ~/.local/share/nvim/odoo, cài bằng scripts/odoo-ls.sh.
return {
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
}
