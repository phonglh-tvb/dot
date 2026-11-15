-- Ba plugin nhỏ cho việc đọc code: nhãn trong comment, màu hiển thị tại chỗ, link GitHub của dòng đang đứng.

-- Nhãn TODO, FIXME, HACK, WARN, PERF, NOTE, TEST trong comment. Tìm toàn bộ dự án bằng :TodoTelescope
-- (dùng ripgrep, đã có trong Brewfile).
require("todo-comments").setup {
  -- Tắt dấu ở cột trái: sign_priority của plugin (8) cao hơn gitsigns (6) nên nó sẽ che dấu thêm/xoá
  -- của git ở đúng những dòng có nhãn. Nhãn vẫn được tô màu trong comment.
  signs = false,
}

-- Màu viết trong code (#rrggbb, rgb(), hsl(), tên màu, class Tailwind) hiện thành một ô vuông đặt
-- trước giá trị. Dùng "virtual" thay vì mặc định "background" để không đè màu của treesitter.
require("nvim-highlight-colors").setup {
  render = "virtual",
  virtual_symbol_position = "inline",
  enable_tailwind = true,
}

-- Link tới GitHub cho dòng (hoặc vùng chọn) đang đứng. Plugin cố ý không gán phím nào,
-- phím ở lua/mappings.lua.
require("gitlinker").setup()
