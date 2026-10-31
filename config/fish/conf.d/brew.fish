# Homebrew vào PATH khi shell chưa thấy brew (máy Linux mới, nơi chưa ai chạy `brew shellenv`).
# Máy đã có brew trong PATH thì giữ nguyên, không đổi gì.
if not type -q brew
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew ~/.linuxbrew/bin/brew
        if test -x $brew_bin
            $brew_bin shellenv fish | source
            break
        end
    end
    set -e brew_bin
end
