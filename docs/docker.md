# Docker và Lima

## VM Lima

Trên macOS Docker chạy trong VM Lima `dev` (không dùng Docker Desktop); cấu hình VM nằm ở [lima/dev.yaml](../lima/dev.yaml) và `./install.sh lima` dựng VM cùng docker context `dev` trên máy mới. Sửa file đó không đổi VM đang chạy (muốn áp dụng thì `limactl edit dev` hoặc tạo lại VM, việc này khởi động lại mọi container nên làm có chủ đích).

VM bật Rosetta nên chạy được image chỉ có bản `linux/amd64`, ví dụ SQL Server: xem [spec 0001](specs/0001-lima-mssql.md).

## Database dev

[docker/docker-compose.yml](../docker/docker-compose.yml) có Postgres (cổng 5433), Valkey (6380), MongoDB (27017) và MySQL (3306), dữ liệu nằm trong volume có tên. Kafka, SQL Server và `pkg-scanner` chỉ chạy khi bật profile `kafka` / `mssql` / `tools`.

```sh
cp docker/env.example docker/.env      # tuỳ chọn: không có thì user / mật khẩu mặc định là dev
docker-compose -f docker/docker-compose.yml up -d
docker-compose -f docker/docker-compose.yml --profile kafka up -d kafka
```

SQL Server 2022 (container `mssql-dev`, cổng 1433, volume `mssql-data`) không có mật khẩu mặc định: đặt `MSSQL_SA_PASSWORD` trước, lấy từ 1Password. Mật khẩu yếu hoặc để trống thì container dừng ngay sau khi chạy (`docker logs mssql-dev` cho biết lý do). Vì sao chạy được trên Apple Silicon: [spec 0001](specs/0001-lima-mssql.md).

```sh
export MSSQL_SA_PASSWORD="$(op read 'op://Dev/mssql-dev/password')"   # đường dẫn op:// là ví dụ
docker-compose -f docker/docker-compose.yml --profile mssql up -d mssql
```

`docker/.env` đã nằm trong `.gitignore`.

## Dọn Docker

`scripts/docker-clean.sh` cho biết Docker đang giữ gì: container đã dừng, image không tên, volume ẩn danh, build cache, và riêng danh sách volume có tên mà không container nào dùng. Mặc định chỉ liệt kê. `--apply` xoá phần an toàn (kèm xác nhận), còn volume có tên chứa dữ liệu nên luôn để bạn tự `docker volume rm`. Công cụ đi kèm trong Brewfile: `lazydocker` (giao diện terminal), `dive` (xem từng layer của image), `hadolint` (kiểm Dockerfile, CI chạy với [.hadolint.yaml](../.hadolint.yaml)), `oha` (thử tải HTTP).

Trên Linux brew chỉ cài Docker CLI, daemon cài tay: xem [linux.md](linux.md).
