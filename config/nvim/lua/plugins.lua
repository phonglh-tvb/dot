-- Plugin quản lý bằng vim.pack (có sẵn trong Neovim 0.12). Lockfile nvim-pack-lock.json nằm trong git:
--   máy mới: mở nvim (hoặc ./install.sh nvim) là cài đúng commit trong lockfile
--   cập nhật: :lua vim.pack.update()  -> xem thay đổi, :write để chấp nhận, rồi commit lockfile
local gh = function(repo)
  return "https://github.com/" .. repo
end

local headless = #vim.api.nvim_list_uis() == 0

-- Cài dở (mất mạng, timeout, Ctrl-C) có thể để lại thư mục chỉ có .git; vim.pack thấy thư mục đã tồn tại
-- nên không cài lại. Xoá những thư mục đó để vim.pack cài lại đúng commit trong lockfile.
local pack_dir = vim.fn.stdpath "data" .. "/site/pack/core/opt"
for name, kind in vim.fs.dir(pack_dir) do
  if kind == "directory" and #vim.fn.readdir(pack_dir .. "/" .. name) <= 1 then
    vim.fn.delete(pack_dir .. "/" .. name, "rf")
  end
end

-- Hook phải đăng ký trước vim.pack.add để bắt cả lần cài đầu tiên
local rebuild_theme = false
local update_parsers = false

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if vim.tbl_contains({ "base46", "ui", "volt", "nvim-web-devicons" }, name) then
      rebuild_theme = true
    elseif name == "nvim-treesitter" and kind == "update" then
      update_parsers = true
    elseif name == "markdown-preview.nvim" then
      -- npm sửa yarn.lock; trả lại để plugin không bị coi là "có thay đổi cục bộ"
      local job = vim.system({ "sh", "-c", "cd app && npm install --no-package-lock && git checkout -- yarn.lock" }, { cwd = path })
      if headless then
        job:wait()
      end
    end
  end,
})

vim.pack.add({
  -- Giao diện NvChad: statusline, tabufline, nvdash, đổi theme (nhánh v3.0 đi cùng NvChad 2.5)
  gh "nvim-lua/plenary.nvim",
  { src = gh "nvchad/base46", version = "v3.0" },
  { src = gh "nvchad/ui", version = "v3.0" },
  gh "nvzone/volt",
  gh "nvzone/menu",
  gh "nvzone/minty",
  gh "nvim-tree/nvim-web-devicons",
  { src = gh "rose-pine/neovim", name = "rose-pine" },

  -- Trình duyệt file, tìm kiếm, git, phím tắt
  gh "nvim-tree/nvim-tree.lua",
  gh "nvim-telescope/telescope.nvim",
  gh "lewis6991/gitsigns.nvim",
  gh "folke/which-key.nvim",
  gh "lukas-reineke/indent-blankline.nvim",
  gh "windwp/nvim-autopairs",
  gh "windwp/nvim-ts-autotag", -- đóng thẻ tự động; Neovim chỉ có sẵn phần đổi tên thẻ (linked editing range)

  -- Ngôn ngữ: parser treesitter, cấu hình LSP (chỉ lấy dữ liệu lsp/*.lua), format, trình cài công cụ
  { src = gh "nvim-treesitter/nvim-treesitter", version = "main" },
  gh "neovim/nvim-lspconfig",
  gh "b0o/SchemaStore.nvim",
  gh "stevearc/conform.nvim",
  gh "mason-org/mason.nvim",
  gh "WhoIsSethDaniel/mason-tool-installer.nvim",

  -- Rust, Java, Go, Python, JS/TS
  { src = gh "mrcjkb/rustaceanvim", version = vim.version.range "^9" },
  gh "saecki/crates.nvim",
  gh "mfussenegger/nvim-jdtls",

  -- Debug (Rust do rustaceanvim, Java do jdtls tự cấu hình adapter)
  gh "mfussenegger/nvim-dap",
  gh "rcarriga/nvim-dap-ui",
  gh "nvim-neotest/nvim-nio",
  gh "theHamsta/nvim-dap-virtual-text",
  gh "leoluz/nvim-dap-go",
  gh "mfussenegger/nvim-dap-python",

  -- Viết tài liệu: Markdown, LaTeX, Typst
  gh "MeanderingProgrammer/render-markdown.nvim",
  gh "iamcco/markdown-preview.nvim",
  gh "lervag/vimtex",
  { src = gh "chomosuke/typst-preview.nvim", version = vim.version.range "1.x" },
}, { confirm = not headless })

-- Theme: rose-pine rồi base46 đè lên, giống thứ tự cũ của NvChad
pcall(vim.cmd.colorscheme, "rose-pine")

if rebuild_theme or not vim.uv.fs_stat(vim.g.base46_cache .. "defaults") then
  require("base46").load_all_highlights()
end
for _, file in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. file)
end
require "nvchad"

require "configs.ui"
require("conform").setup(require "configs.conform")
require "configs.mason"
require "configs.writing"
require "configs.lspconfig"

vim.g.rustaceanvim = function()
  return require "configs.rust"
end

-- Parser treesitter: bất đồng bộ, bỏ qua những parser đã có
vim.schedule(function()
  require("configs.dap").setup()

  if update_parsers then
    require("nvim-treesitter").update()
  elseif not headless then
    require("configs.treesitter").install()
  end
end)
