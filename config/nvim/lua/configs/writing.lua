-- Markdown / LaTeX / Typst, và crates.nvim cho Cargo.toml

-- Markdown: render ngay trong buffer
require("render-markdown").setup {
  file_types = { "markdown" },
  completions = { lsp = { enabled = true } },
}

-- Markdown: preview trên trình duyệt (KaTeX, mermaid); bước build nằm trong hook PackChanged (plugins.lua)
vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_auto_close = 0

-- LaTeX: các biến vimtex phải đặt trước khi plugin được nạp
if vim.uv.fs_stat "/Applications/Skim.app" then
  -- Skim cho forward/inverse search
  vim.g.vimtex_view_method = "skim"
  vim.g.vimtex_view_skim_sync = 1
  vim.g.vimtex_view_skim_activate = 1
elseif vim.fn.executable "zathura" == 1 then
  vim.g.vimtex_view_method = "zathura"
else
  vim.g.vimtex_view_method = "general"
end

-- Engine Unicode để gõ tiếng Việt trực tiếp; đổi từng file bằng `% !TEX program = pdflatex`
vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
vim.g.vimtex_quickfix_open_on_warning = 0

-- Typst: setup() tải websocat ở lần đầu nên chỉ chạy khi thật sự mở file typst
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  once = true,
  callback = function()
    require("typst-preview").setup { dependencies_bin = { tinymist = "tinymist" } }
  end,
})

-- Version / feature completion và code action trong Cargo.toml
require("crates").setup {
  lsp = { enabled = true, actions = true, completion = true, hover = true },
}
