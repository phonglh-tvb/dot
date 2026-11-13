# Spec

Spec là bản thiết kế viết *trước* khi làm một việc lớn: vấn đề là gì, muốn đạt gì, làm thế nào, đã bỏ hướng nào và vì sao, kiểm chứng ra sao. Ba loại tài liệu bổ trợ nhau:

- **Spec** (thư mục này): vì sao làm thế này, còn giá trị lâu sau khi PR đã merge.
- **PR**: lần thay đổi này làm gì, đã kiểm gì.
- **[CHANGELOG.md](../../CHANGELOG.md)**: repo đã đổi gì, theo ngày.

## Khi nào viết

Viết khi việc có nhiều hướng thật sự khác nhau, thêm một thành phần hay bước cài mới, thay một công cụ đang dùng, hoặc dựng thứ chạy lâu trên máy (VM, container giữ dữ liệu). Sửa lỗi, nâng cấp thường lệ hay thêm một gói thì phần phân tích trong PR là đủ.

## Cách viết

1. Chép [_template.md](_template.md) thành `NNNN-<slug>.md`, `NNNN` là số kế tiếp trong bảng dưới.
2. Viết trong cùng PR với thay đổi; cần chốt hướng trước khi làm thì mở PR riêng chỉ có spec.
3. Thêm một dòng vào bảng dưới.
4. Spec là hồ sơ, không sửa lại cho khớp hiện tại: hướng đổi thì viết spec mới và ghi "thay bởi NNNN" ở trạng thái spec cũ, không xoá file.

Trạng thái: `nháp` (đang bàn), `đã làm` (đã merge), `thay bởi NNNN`, `bỏ`.

## Danh sách

| Số | Spec | Trạng thái |
|---|---|---|
| 0001 | [SQL Server trên Docker context `dev` (Lima)](0001-lima-mssql.md) | đã làm |
