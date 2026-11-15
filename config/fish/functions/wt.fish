# Liệt kê worktree của repo hiện tại thành "<nhánh>\t<đường dẫn>". Dùng --porcelain thay vì
# `git worktree list` để đường dẫn có dấu cách cũng đúng.
function _wt_list
    set -l path ""
    for line in (git worktree list --porcelain)
        switch $line
            case 'worktree *'
                set path (string replace -r '^worktree ' '' -- $line)
            case 'branch *'
                printf '%s\t%s\n' (string replace -r '^branch refs/heads/' '' -- $line) $path
            case detached
                printf '%s\t%s\n' '(detached)' $path
        end
    end
end

function wt --description 'Chọn worktree của repo hiện tại bằng fzf rồi cd vào đó'
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "wt: không ở trong repo git" >&2
        return 1
    end

    set -l chosen (_wt_list | fzf --layout reverse --prompt 'worktree> ' --delimiter \t --with-nth 1,2)
    test -n "$chosen"; and cd (string split -f2 \t -- $chosen)
end
