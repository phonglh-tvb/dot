-- Neovim tự lo highlight / indent / fold bằng treesitter; nvim-treesitter (nhánh main) chỉ dùng để cài parser.
local M = {}

M.parsers = {
  "vim", "lua", "luadoc", "vimdoc", "printf",
  -- web / frontend
  "html", "css", "scss", "javascript", "typescript", "tsx", "json", "yaml", "toml", "prisma",
  -- backend
  "python", "go", "gomod", "gosum", "gowork", "gotmpl", "rust", "java", "c", "php",
  -- Odoo: view / QWeb là xml
  "xml",
  -- tài liệu
  "markdown", "markdown_inline", "latex", "bibtex", "typst",
  -- khác
  "bash", "dockerfile", "sql", "regex", "diff", "gitcommit", "git_rebase", "gitignore", "ini", "make",
}

---@return table task nhả ra từ nvim-treesitter; gọi :wait(ms) nếu cần chạy đồng bộ
function M.install()
  return require("nvim-treesitter").install(M.parsers)
end

return M
