# sops đọc khoá age từ $SOPS_AGE_KEY_FILE; mặc định macOS và Linux khác nhau nên cố định một chỗ.
# Chỉ là đường dẫn, không phải secret; đừng bao giờ `set -Ux` một secret thật (nó ghi plain text vào fish_variables).
set -gx SOPS_AGE_KEY_FILE $HOME/.config/sops/age/keys.txt
