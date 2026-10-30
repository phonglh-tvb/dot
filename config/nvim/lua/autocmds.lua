local autocmd = vim.api.nvim_create_autocmd

-- Treesitter highlight cho mọi filetype có parser (giống NvChad); không có parser thì pcall bỏ qua
autocmd("FileType", {
  pattern = "*",
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_user_command("TSInstallAll", function()
  require("configs.treesitter").install()
end, {})

-- Indent theo ngôn ngữ (options.lua mặc định 2 space; ftplugin chạy trước nên autocmd này ghi đè)
local indent = {
  python = { 4, true },
  java = { 4, true },
  rust = { 4, true },
  xml = { 4, true }, -- view / QWeb của Odoo
  go = { 4, false }, -- gofmt dùng tab
}

for ft, style in pairs(indent) do
  autocmd("FileType", {
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
autocmd("FileType", {
  pattern = { "javascriptreact", "typescriptreact", "html" },
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Java: nvim-jdtls tự quản lý client, không qua vim.lsp.enable
autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserJdtls", { clear = true }), -- không dùng "jdtls": plugin/jdtls.lua của nvim-jdtls clear group cùng tên
  pattern = "java",
  callback = function(args)
    require("configs.jdtls").start(args.buf)
  end,
})

-- Viết tài liệu: markdown / latex / typst
local prose = vim.api.nvim_create_augroup("Prose", { clear = true })

autocmd("FileType", {
  group = prose,
  pattern = { "markdown", "tex", "plaintex", "typst" },
  callback = function(args)
    local wo = vim.wo[0][0]
    wo.wrap = true
    wo.linebreak = true
    wo.list = false -- listchars (eol, trail) rất rối trên văn bản wrap
    wo.spell = false -- không có từ điển tiếng Việt; bật bằng <leader>ms khi viết tiếng Anh

    -- di chuyển theo dòng hiển thị khi không có count
    for key, move in pairs { j = "gj", k = "gk" } do
      vim.keymap.set(
        { "n", "x" },
        key,
        ("v:count == 0 ? '%s' : '%s'"):format(move, key),
        { buf = args.buf, expr = true, desc = "Move by display line" }
      )
    end

    vim.keymap.set(
      "n",
      "<leader>ms",
      "<cmd>setlocal spell! spelllang=en<cr>",
      { buf = args.buf, desc = "Toggle spell (en)" }
    )
  end,
})

-- vimtex dùng syntax của nó (conceal, mathzone); treesitter highlight sẽ đè lên
autocmd("FileType", {
  group = prose,
  pattern = { "tex", "plaintex", "bibtex" },
  callback = function(args)
    pcall(vim.treesitter.stop, args.buf)
    vim.bo[args.buf].syntax = "on"
  end,
})

-- Phím tắt <leader>m*: cùng một chữ cái, tuỳ loại file
local function ft_maps(ft, maps)
  autocmd("FileType", {
    group = prose,
    pattern = ft,
    callback = function(args)
      for _, m in ipairs(maps) do
        vim.keymap.set("n", m[1], m[2], { buf = args.buf, desc = m[3] })
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

-- Debug test Go (nvim-dap-go)
ft_maps("go", {
  {
    "<leader>dT",
    function()
      require("dap-go").debug_test()
    end,
    "Debug nearest Go test",
  },
  {
    "<leader>dL",
    function()
      require("dap-go").debug_last_test()
    end,
    "Debug last Go test",
  },
})
