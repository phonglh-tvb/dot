-- Neovim chưa có trình cài LSP / formatter / debugger gốc nên dùng Mason;
-- danh sách gói ở configs/tools.lua, mason-tool-installer cài những gói còn thiếu.
require("mason").setup {
  PATH = "skip", -- options.lua đã thêm mason/bin vào PATH

  ui = {
    icons = {
      package_pending = " ",
      package_installed = " ",
      package_uninstalled = " ",
    },
  },

  max_concurrent_installers = 10,
}

require("mason-tool-installer").setup {
  ensure_installed = require "configs.tools",
  start_delay = 3000,
}
