# Cách dùng Neovim

Hướng dẫn dùng hằng ngày: phím tắt và quy trình làm việc. Cấu hình được dựng thế nào (plugin, LSP, vì sao chọn công cụ nào) xem mục Neovim trong [README chính](../../README.md#neovim).

Phím leader là `Space`. Bảng dưới đây khớp với `lua/mappings.lua` và `lua/configs/lspconfig.lua`; đổi phím thì sửa cả file này.

## Bắt đầu

- Mở nvim trong thư mục dự án (`cd <dự án> && nvim`): LSP tìm gốc dự án từ file đang mở.
- Quên phím: nhấn `Space` rồi chờ, which-key hiện các phím tiếp theo. `Space wK` liệt kê mọi phím, `Space ch` mở bảng tra của NvChad.
- `;` thay cho `:` (vào chế độ lệnh), `jk` thoát insert mode, `Ctrl-s` lưu file.

## Tìm và mở file

| Phím | Việc |
|---|---|
| `Ctrl-n` / `Space e` | Bật/tắt cây thư mục / nhảy vào cây thư mục |
| `Space ff` | Tìm file theo tên (`Space fa` tìm cả file ẩn và file bị ignore) |
| `Space fw` | Tìm chữ trong toàn dự án (live grep) |
| `Space fo` / `Space fb` | File mở gần đây / các buffer đang mở |
| `Tab` / `Shift-Tab` / `Space x` | Sang buffer sau / buffer trước / đóng buffer |
| `Ctrl-h/j/k/l` | Chuyển qua lại giữa các cửa sổ chia |

## Viết code (LSP)

| Phím | Việc |
|---|---|
| Gõ chữ | Gợi ý tự hiện. `Tab`/`Shift-Tab` chọn, `Ctrl-y` chấp nhận, `Ctrl-Space` gọi gợi ý bằng tay |
| `K` | Xem tài liệu, kiểu dữ liệu của thứ dưới con trỏ |
| `gd` / `gD` / `Space D` | Tới định nghĩa / khai báo / định nghĩa kiểu |
| `grr` / `gri` | Tìm mọi chỗ dùng / tìm implementation |
| `Space ra` (hoặc `grn`) | Đổi tên ở mọi nơi |
| `gra` | Code action: thêm `using`/import, sửa lỗi nhanh, tách biến... |
| `Space fm` | Format file (conform; ngôn ngữ không có formatter riêng thì dùng LSP) |
| `Space uh` | Bật/tắt inlay hint (kiểu ngầm định, tên tham số) |
| `]d` / `[d` | Nhảy tới lỗi sau / lỗi trước |
| `Space fd` / `Space qd` | Danh sách lỗi trong Telescope / trong quickfix |
| `Space fs` / `Space fS` | Symbol trong file / trong toàn dự án |
| `Space /` | Comment hoặc bỏ comment dòng (visual mode: cả vùng chọn) |

LSP bị đơ thì `:lsp restart`; kiểm tra bằng `:checkhealth vim.lsp`.

## Terminal trong nvim

| Phím | Việc |
|---|---|
| `Alt-h` / `Alt-v` / `Alt-i` | Bật/tắt terminal nằm ngang / nằm dọc / nổi giữa màn hình |
| `Ctrl-x` | Thoát terminal mode để di chuyển như buffer thường |

## Debug

Dùng chung cho mọi ngôn ngữ có cấu hình nvim-dap (Go, Python, JS/TS, C#; Rust và Java do rustaceanvim và nvim-jdtls tự cấu hình).

| Phím | Việc |
|---|---|
| `Space db` / `Space dB` | Đặt breakpoint / breakpoint có điều kiện |
| `Space dc` | Bắt đầu debug (lần đầu chọn cấu hình) hoặc chạy tiếp |
| `Space do` / `Space di` / `Space dO` | Step over / step into / step out |
| `Space de` | Xem giá trị biểu thức dưới con trỏ hoặc vùng chọn |
| `Space du` / `Space dr` | Bật/tắt giao diện debug / REPL |
| `Space dl` / `Space dt` | Chạy lại lần debug trước / dừng debug |

## C# / .NET

Cần `mise install` để có `dotnet`, `roslyn-language-server`, `netcoredbg` và `dotnet-aspnet-codegenerator`.

**LSP.** Mở file `.cs`, `.cshtml` hoặc `.razor` trong thư mục có `.csproj` hoặc `.sln` là Roslyn tự chạy; lần đầu mất vài giây để nạp dự án. Thư mục có nhiều solution thì chọn bằng `:Roslyn target`. Kiểm tra bằng `:checkhealth roslyn`.

**Sinh code: `:Scaffold` (`Space cs`).**

1. Mở file model, ví dụ `Models/Product.cs`.
2. `Space cs`, chọn kiểu sinh: controller kèm view (MVC), một view riêng, Razor Pages, Blazor hoặc Minimal API.
3. Trả lời vài câu hỏi; giá trị mặc định thường dùng được luôn. DbContext có sẵn trong dự án thì tự dùng.
4. File sinh ra mở ngay, danh sách đầy đủ ở quickfix (`Space ql`). `:Scaffold!` ghi đè file đã có.

Dự án cần các package scaffold liệt kê trong README chính. Khi tool tạo DbContext mới, nó ghi connection string LocalDB (chỉ có trên Windows): trên macOS và Linux đổi sang database thật, ví dụ Postgres của `docker/docker-compose.yml`.

**Debug.** `Space dc` rồi chọn "C#: build and launch" (tự `dotnet build` rồi chạy dll của dự án) hoặc "C#: attach to process". Cấu hình này chạy thẳng dll nên không đọc `Properties/launchSettings.json`: app web nghe ở `http://localhost:5000` thay vì cổng của `dotnet run`.

**Quy trình thường gặp** (dự án ASP.NET dùng EF Core):

1. Sửa hoặc thêm model.
2. `Space cs` để sinh controller và view.
3. `Alt-i` mở terminal: `dotnet ef migrations add <Tên>` rồi `dotnet ef database update`. `dotnet-ef` cài làm local tool của dự án: `dotnet new tool-manifest && dotnet tool install dotnet-ef`.
4. `dotnet run` để chạy, hoặc `Space dc` để debug.

## Bảo trì

- Cập nhật plugin: `:lua vim.pack.update()`, xem thay đổi, `:write` để chấp nhận, rồi commit `nvim-pack-lock.json` qua PR.
- LSP, formatter, debug adapter của các ngôn ngữ khác do Mason quản lý (`:Mason`, danh sách ở `lua/configs/tools.lua`). Công cụ C# do mise quản lý: `mise upgrade --no-prune`.
- Sau khi nâng cấp Neovim hay plugin: `:checkhealth vim.deprecated` phải sạch.
