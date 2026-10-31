# Chỉ nạp khi đã cài rustup (bước `rust` của install.sh); máy mới chưa có thì không báo lỗi mỗi lần mở shell.
test -f "$HOME/.cargo/env.fish"; and source "$HOME/.cargo/env.fish"
