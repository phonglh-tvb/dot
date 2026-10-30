local opt = vim.opt
local o = vim.o
local g = vim.g

---------------------------------- mặc định của NvChad v2.5 ----------------------------------
-- (chép lại từ nvchad/options.lua vì không còn dùng NvChad)
o.laststatus = 3
o.showmode = false
o.splitkeep = "screen"

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "number"

o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

o.number = true
o.numberwidth = 2
o.ruler = false

opt.shortmess:append "sI"

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.undofile = true

-- chu kỳ ghi swap, gitsigns cũng dùng
o.updatetime = 250

-- h, l, mũi tên đi sang dòng trước / sau khi tới đầu / cuối dòng
opt.whichwrap:append "<>[]hl"

g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- binary do Mason cài
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin:" .. vim.env.PATH

---------------------------------- của bạn ----------------------------------
-- Template html/template của Go: parser gotmpl không inject HTML nên soạn như HTML
-- (highlight, emmet, tự đóng tag đều dùng được)
vim.filetype.add { extension = { gohtml = "html" } }

opt.number = true
opt.softtabstop = 2
opt.tabstop = 4
opt.shiftwidth = 2
opt.expandtab = true
-- Completion gốc của Neovim (vim.lsp.completion): popup, không chọn sẵn; <C-y> hoặc <CR> khi đã chọn
opt.completeopt = { "menuone", "noselect", "popup" }
opt.clipboard = "unnamedplus"
opt.wildmode = { "longest", "list", "full" }
opt.wildmenu = true
if vim.fn.executable "zsh" == 1 then
  opt.sh = "zsh"
end
opt.cursorline = true
opt.termguicolors = true
opt.list = true
opt.guifont = "JetBrainsMono Nerd Font Mono:h24"
opt.showbreak = "↪ "
opt.listchars = {
  tab = "→ ",
  eol = "↲",
  nbsp = "␣",
  trail = "•",
  extends = "⟩",
  precedes = "⟨",
}

opt.foldmethod = "indent"
opt.foldnestmax = 10
opt.foldenable = false
opt.autoread = true
opt.showtabline = 2

opt.undofile = true
opt.undodir = vim.fn.expand "$HOME/.tmp/nvim/undo"
vim.fn.mkdir(vim.o.undodir, "p")
opt.undolevels = 1000
opt.undoreload = 10000
opt.ttimeout = true
opt.ttimeoutlen = 0
opt.inccommand = "nosplit"
opt.mouse = "a"
if g.catppuccin_flavour == nil then
  g.catppuccin_flavour = "frappe"
end
