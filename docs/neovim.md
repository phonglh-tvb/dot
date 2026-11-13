# Neovim

Cấu hình thuần Neovim 0.12, không dùng NvChad (bản distribution) hay lazy.nvim. Những gì Neovim đã có sẵn thì dùng bản gốc: `vim.pack` (quản lý plugin), `vim.lsp.config` / `vim.lsp.enable`, completion và snippet LSP (`vim.lsp.completion`, `vim.snippet`), `gc` để comment, treesitter highlight. Giao diện (statusline, tabufline, nvdash, đổi theme) vẫn là plugin `nvchad/ui` + `nvchad/base46`, chạy độc lập.

File này nói cấu hình được dựng thế nào. Cách dùng hằng ngày (phím tắt, debug, quy trình C#) ở [config/nvim/README.md](../config/nvim/README.md).

## Bố cục

Trong `config/nvim/`:

```
init.lua                 vào cấu hình
lua/plugins.lua          danh sách plugin (vim.pack) + hook build
lua/options.lua          tuỳ chọn (gồm mặc định NvChad đã chép lại)
lua/mappings.lua         phím tắt (giữ nguyên bộ phím NvChad)
lua/autocmds.lua         indent theo ngôn ngữ, viết tài liệu, Java
lua/configs/             lspconfig, conform, dap, jdtls, rust, scaffold (:Scaffold), tools (danh sách Mason), ui, writing
nvim-pack-lock.json      commit của từng plugin (đưa vào git)
README.md                cách dùng: phím tắt và quy trình làm việc
```

## Plugin và công cụ

- Plugin ghim bằng `nvim-pack-lock.json`: máy mới mở nvim (hoặc `./install.sh nvim`) là cài đúng commit.
- Cập nhật plugin: `:lua vim.pack.update()`, xem thay đổi, `:write` để chấp nhận, rồi commit lockfile. Hoàn lại: `git checkout HEAD -- nvim-pack-lock.json` rồi `:restart`.
- Công cụ (LSP, formatter, debug adapter) khai báo một chỗ trong `lua/configs/tools.lua`; `mason-tool-installer` tự cài những gói còn thiếu. Cài lại bằng tay: `:MasonToolsInstall`.
- Cài plugin bị ngắt giữa chừng: khởi động sau sẽ tự xoá thư mục hỏng và cài lại.

## C# / .NET

- LSP là `roslyn.nvim` (có Razor, tức `.cshtml` và `.razor`; `roslyn_ls` của nvim-lspconfig thì không). Ba công cụ cài bằng `mise install` chứ không qua Mason, vì Mason đang giữ `roslyn-language-server` cũ hơn mức roslyn.nvim yêu cầu và `netcoredbg` chỉ có bản x86_64 (macOS arm64 phải chạy qua Rosetta). Debug: `netcoredbg` qua nvim-dap, cấu hình "C#: build and launch" tự `dotnet build` rồi chạy dll của project.
- `:Scaffold` (`<leader>cs`) làm việc như "Add > New Scaffolded Item" của Visual Studio: đứng trong file model, chọn controller + view (MVC), một view riêng, Razor Pages, Blazor hoặc Minimal API. Model lấy từ class đang đứng, DbContext tự tìm trong project (không thấy thì hỏi tên), file sinh ra mở ngay và nằm trong quickfix (`<leader>ql`). `:Scaffold!` ghi đè file đã có. Engine là `dotnet-aspnet-codegenerator`, nên project cần các package `Microsoft.VisualStudio.Web.CodeGeneration.Design` và `Microsoft.EntityFrameworkCore.SqlServer` / `.Tools` (Blazor thêm `Microsoft.AspNetCore.Components.QuickGrid`, Minimal API thêm `Microsoft.AspNetCore.OpenApi` nếu bật OpenAPI); thiếu gói nào tool tự báo.

## Odoo

`odoo_ls` chỉ gắn vào `python` và `xml` khi project có `odools.toml`. Binary và typeshed do `./install.sh odoo` cài, bản và sha256 ghim trong `scripts/odoo-ls.sh`. Nâng bản: sửa `VERSION` và sha256 theo trang release, đọc ghi chú phát hành và `config_schema.json` của release đó trước (khoá của `odools.toml` có thể đổi). Bản cũ được giữ thành `odoo_ls_server.<bản cũ>` và `typeshed.<bản cũ>`; quay lại bằng `mv` ngược.
