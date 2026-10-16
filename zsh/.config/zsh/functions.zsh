# yazi
function y() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"

    if [[ -f "$tmp" ]]; then
        local cwd
        cwd="$(cat "$tmp")"

        if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
            cd "$cwd"
        fi
    fi

    rm -f "$tmp"
}


# eject disk function
ejectdisk() {
    echo "Ejecting external disk..."
    ~/.local/bin/eject-storage.sh

    if [[ $? -eq 0 ]]; then
        echo "Done. Safe to unplug."
    else
        echo "Something went wrong."
    fi
}
