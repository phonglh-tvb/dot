# macOS: ssh-agent của launchd trống sau mỗi lần khởi động máy. ssh tự nạp khoá được (AddKeysToAgent + UseKeychain),
# nhưng `ssh-keygen -Y sign` (ký commit) thì không, nên khoá có passphrase sẽ làm mỗi lần commit hỏi lại.
# Nạp các khoá đã lưu passphrase trong Keychain (`ssh-add --apple-use-keychain <khoá>`) một lần cho mỗi agent:
# lệnh này mất ~0,5 giây nên không chạy ở mọi shell, chỉ chạy khi đường dẫn socket của agent đổi (sau khởi động lại).
# Dùng bản của hệ thống vì ssh-add của Homebrew không có cờ này.
if status is-interactive; and test (uname) = Darwin; and test -x /usr/bin/ssh-add; and set -q SSH_AUTH_SOCK
    if test "$__ssh_keychain_loaded" != "$SSH_AUTH_SOCK"
        /usr/bin/ssh-add --apple-load-keychain 2>/dev/null
        set -U __ssh_keychain_loaded $SSH_AUTH_SOCK
    end
end
