require "nvchad.autocmds"

-- Indent theo ngôn ngữ (options.lua mặc định 2 space; ftplugin chạy trước nên autocmd này ghi đè)
local indent = {
  python = { 4, true },
  java = { 4, true },
  rust = { 4, true },
  xml = { 4, true }, -- view / QWeb của Odoo
  go = { 4, false }, -- gofmt dùng tab
}

for ft, style in pairs(indent) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    callback = function()
      vim.bo.tabstop = style[1]
      vim.bo.shiftwidth = style[1]
      vim.bo.softtabstop = style[1]
      vim.bo.expandtab = style[2]
    end,
  })
end

-- Treesitter indent cho jsx/tsx/html (indent mặc định của vim kém ở các ngôn ngữ này)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascriptreact", "typescriptreact", "html" },
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Viết tài liệu: markdown / latex / typst
local prose = vim.api.nvim_create_augroup("Prose", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = prose,
  pattern = { "markdown", "tex", "plaintex", "typst" },
  callback = function(args)
    local wo = vim.wo[0][0]
    wo.wrap = true
    wo.linebreak = true
    wo.list = false -- listchars (eol, trail) rất rối trên văn bản wrap
    wo.spell = false -- không có từ điển tiếng Việt; bật bằng <leader>ms khi viết tiếng Anh

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
    end

    -- di chuyển theo dòng hiển thị khi không có count
    for key, move in pairs { j = "gj", k = "gk" } do
      vim.keymap.set(
        { "n", "x" },
        key,
        ("v:count == 0 ? '%s' : '%s'"):format(move, key),
        { buffer = args.buf, expr = true, desc = "Move by display line" }
      )
    end

    map("<leader>ms", "<cmd>setlocal spell! spelllang=en<cr>", "Toggle spell (en)")
  end,
})

-- vimtex dùng syntax của nó (conceal, mathzone); treesitter highlight sẽ đè lên
vim.api.nvim_create_autocmd("FileType", {
  group = prose,
  pattern = { "tex", "plaintex", "bibtex" },
  callback = function(args)
    pcall(vim.treesitter.stop, args.buf)
    vim.bo[args.buf].syntax = "on"
  end,
})

-- Phím tắt <leader>m*: cùng một chữ cái, tuỳ loại file
local function ft_maps(ft, maps)
  vim.api.nvim_create_autocmd("FileType", {
    group = prose,
    pattern = ft,
    callback = function(args)
      for _, m in ipairs(maps) do
        vim.keymap.set("n", m[1], m[2], { buffer = args.buf, desc = m[3] })
      end
    end,
  })
end

ft_maps("markdown", {
  { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", "Markdown preview (browser)" },
  { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", "Markdown toggle in-buffer render" },
})

ft_maps("typst", {
  { "<leader>mp", "<cmd>TypstPreviewToggle<cr>", "Typst live preview" },
  { "<leader>me", "<cmd>LspTinymistExportPdf<cr>", "Typst export PDF" },
  { "<leader>mm", "<cmd>LspTinymistPinMain<cr>", "Typst pin main file" },
})

ft_maps({ "tex", "plaintex" }, {
  { "<leader>mp", "<cmd>VimtexCompile<cr>", "LaTeX compile (toggle continuous)" },
  { "<leader>mv", "<cmd>VimtexView<cr>", "LaTeX view PDF" },
  { "<leader>mo", "<cmd>VimtexTocToggle<cr>", "LaTeX table of contents" },
  { "<leader>mc", "<cmd>VimtexClean<cr>", "LaTeX clean aux files" },
  { "<leader>mi", "<cmd>VimtexInfo<cr>", "LaTeX info" },
})

-- Debug test Go (nvim-dap-go); nạp nvim-dap trước vì nó lazy-load theo phím <leader>d*
local function dap_go(fn)
  return function()
    require("lazy").load { plugins = { "nvim-dap" } }
    require("dap-go")[fn]()
  end
end

ft_maps("go", {
  { "<leader>dT", dap_go "debug_test", "Debug nearest Go test" },
  { "<leader>dL", dap_go "debug_last_test", "Debug last Go test" },
})
