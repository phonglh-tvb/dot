-- Neovim 0.12 thuần: plugin do vim.pack quản lý, giao diện là plugin nvchad/ui (không dùng NvChad)
vim.g.mapleader = " "
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"

require "options"
require "plugins"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
