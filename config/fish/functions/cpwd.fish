function cpwd --description 'Chép đường dẫn thư mục hiện tại vào clipboard (rút gọn $HOME thành ~)'
    set -l path (string replace -- "$HOME" '~' "$PWD")

    # Lệnh clipboard chọn theo máy, cùng thứ tự với copy-command của tmux
    if command -q pbcopy
        printf '%s' $path | pbcopy
    else if command -q wl-copy
        printf '%s' $path | wl-copy
    else if command -q xclip
        printf '%s' $path | xclip -selection clipboard -in
    else
        echo "cpwd: không có pbcopy, wl-copy hay xclip" >&2
        return 1
    end

    echo $path
end
