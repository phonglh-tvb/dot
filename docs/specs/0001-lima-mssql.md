# 0001: SQL Server trên Docker context `dev` (Lima)

- **Trạng thái:** đã làm
- **Ngày:** 2026-09-16 (đưa vào repo 2026-11-13)
- **PR:** [#22](https://github.com/phonglh-tvb/dot/pull/22) (chỉ đưa spec vào repo; VM đã có trong repo từ [#7](https://github.com/phonglh-tvb/dot/pull/7))
- **Liên quan:** [lima/dev.yaml](../../lima/dev.yaml), [docs/docker.md](../docker.md)

## Bối cảnh

Mac Apple Silicon dùng CPU `arm64`, còn image SQL Server Linux chính thức chỉ có `amd64`/`x86_64`.

Docker engine trên Mac thường là môi trường Linux `arm64`. Image không có bản arm64 thì Docker báo `no matching manifest for linux/arm64`; ép dùng image amd64 mà thiếu lớp tương thích thì chương trình báo `exec format error`. Docker chỉ quản lý container, không tự chuyển chương trình amd64 thành arm64: muốn chạy khác kiến trúc cần Rosetta 2 hoặc QEMU.

## Mục tiêu

Một môi trường Docker Linux riêng trên macOS Apple Silicon để chạy SQL Server 2022 Developer, dùng context `dev`, chạy thêm được service khác, và giữ dữ liệu database qua các lần dừng hoặc tạo lại container.

Ngoài phạm vi: database production. Microsoft chỉ hỗ trợ SQL Server container trên host Linux `x86-64`; chạy qua emulation trên Apple Silicon chỉ dành cho phát triển local.

## Thiết kế

Luồng chạy:

```text
macOS arm64 -> Lima VM Linux arm64 -> Docker Engine -> image MSSQL linux/amd64 -> Rosetta/binfmt
```

VM dùng `vmType: vz`, bật Rosetta và `binfmt_misc`. Docker rootful chạy trong VM; socket Docker được forward ra host để Docker CLI kết nối qua context `dev`. Lima không có image MSSQL riêng: nó chỉ tạo môi trường Linux có đường chạy binary amd64, Docker bên trong vẫn chạy image MSSQL thông thường.

| Thành phần | Giá trị |
|---|---|
| Lima instance | `dev` |
| Docker context | `dev` |
| VM | Ubuntu 24.04 minimal arm64, 4 CPU, 6 GiB RAM, 100 GiB đĩa |
| Container | `mssql-dev` |
| Image | `mcr.microsoft.com/mssql/server:2022-latest` (`linux/amd64`) |
| Cổng trên host | `1433` |
| Volume dữ liệu | `mssql-data` |

Cấu hình VM ở [lima/dev.yaml](../../lima/dev.yaml):

- Ubuntu minimal arm64: nhẹ, hợp Apple Silicon.
- 4 CPU, 6 GiB RAM: đủ cho SQL Server và vài service phụ.
- 100 GiB đĩa: chỗ cho image, database và service dự án.
- Socket Docker forward ra host: Docker CLI trên macOS dùng được context `dev`.

### Dựng

`./install.sh lima` tạo VM `dev` từ `lima/dev.yaml` và docker context `dev` (VM hay context đã có thì giữ nguyên).

Mật khẩu `sa` lấy từ 1Password, không ghi vào repo hay lịch sử lệnh ([docs/secrets.md](../secrets.md)). SQL Server đòi mật khẩu mạnh (ít nhất 8 ký tự, có 3 trong 4 loại: chữ hoa, chữ thường, số, ký hiệu); mật khẩu yếu thì container dừng ngay sau khi chạy.

```sh
export MSSQL_SA_PASSWORD="$(op read 'op://Dev/mssql-dev/password')"   # đường dẫn op:// là ví dụ
docker --context dev run -d --name mssql-dev --platform linux/amd64 \
  -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD \
  -p 1433:1433 -v mssql-data:/var/opt/mssql \
  mcr.microsoft.com/mssql/server:2022-latest
```

Kết nối: ứng dụng trên macOS dùng `localhost,1433`, user `sa`, bật `TrustServerCertificate`. Container khác trong cùng Docker context dùng `mssql-dev,1433`.

### Vận hành hằng ngày

```sh
docker context use dev
docker ps
docker stop mssql-dev
docker start mssql-dev
```

Dừng hoặc chạy lại cả VM bằng `limactl stop dev` và `limactl start dev` (kéo theo mọi container trong VM).

### Dữ liệu và reset

Container tạo lại được; volume `mssql-data` chứa database và cần giữ nếu muốn còn dữ liệu.

```sh
docker rm -f mssql-dev                  # xoá container, giữ database
docker rm -f mssql-dev && docker volume rm mssql-data   # xoá cả database local
```

Xoá Lima instance `dev` là xoá toàn bộ image, container và volume trong VM; không khôi phục được nếu không có bản sao lưu.

## Phương án đã cân nhắc

**Docker Desktop.** Cũng chạy được: Docker Desktop trên Apple Silicon cũng chạy Linux trong một VM và dùng Rosetta hoặc QEMU để chạy container `linux/amd64`, nên câu "Docker thường không cài được MSSQL" là quá tuyệt đối. Điều chính xác hơn:

1. Image MSSQL chính thức là `amd64`, không có bản `arm64`.
2. Docker Desktop phải bật đúng cơ chế emulation và backend VM tương thích. Tuỳ phiên bản và backend, Rosetta có thể có hoặc không; không có Rosetta thì dùng QEMU, thường chậm hơn.
3. `--platform=linux/amd64` chỉ chọn image amd64, không bảo đảm emulation đang chạy.
4. Tài liệu Docker ghi nhận chạy image Intel trên Apple Silicon bằng emulation là *best effort*: có thể chậm, tốn RAM hoặc crash.

Lima không làm MSSQL "được hỗ trợ chính thức" hơn. Lý do chọn Lima: một VM riêng, cấu hình Rosetta/binfmt ghi rõ trong file, Docker context độc lập, và cả máy dùng chung một runtime (không cài Docker Desktop).

## Đánh đổi và đường lui

Được: chạy được image MSSQL amd64, không ảnh hưởng Docker daemon khác, dễ thêm service, volume rõ ràng, reset bằng cách tạo lại VM.

Mất: MSSQL chạy qua emulation nên chậm hơn x86_64 native, cần cấp đủ RAM, không dùng cho production, image chiếm vài GB đĩa.

Đường lui: `docker rm -f mssql-dev` (giữ volume) gỡ SQL Server mà không đụng service khác trong VM.

## Kiểm chứng

```sh
docker context show     # dev
docker version          # phần Server là Docker Engine trong VM Lima
docker ps               # mssql-dev đang Up, 0.0.0.0:1433->1433/tcp
docker exec mssql-dev /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q 'SELECT @@VERSION'
```

Đạt khi context hiện tại là `dev`, Docker server chạy trong Lima, MSSQL amd64 chạy qua Rosetta/binfmt, cổng `1433` mở và truy vấn trả về SQL Server 2022 Developer Edition. Đã kiểm ngày 2026-09-16: `SELECT @@VERSION` trả về bản 2022 Developer Edition và log báo sẵn sàng nhận kết nối.

Lệnh `docker run` ở trên được viết lại khi đưa spec vào repo (bản gốc không ghi lệnh tạo container) và chưa chạy lại.

## Câu hỏi mở

- `mssql-dev` chưa có trong [docker/docker-compose.yml](../../docker/docker-compose.yml) như Postgres, MySQL; thêm vào (sau một profile, vì image nặng và chạy qua emulation) thì không phải nhớ lệnh `docker run`.
