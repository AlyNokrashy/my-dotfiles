# =========================================================
# Keybindings
# =========================================================

# Vi-style keymaps: the line editor starts in insert mode and Esc enters
# normal mode. Must come before the bindings below, which are made without
# -M and therefore land in the active (insert) keymap.
bindkey -v

# Esc -> normal mode is subject to this delay (hundredths of a second).
# zsh's default is 40 (0.4s), which makes Esc feel laggy in vi mode.
KEYTIMEOUT=10

# Ctrl+Right -> move forward one word (^[[1;5C is the terminal escape code)
bindkey '^[[1;5C' forward-word

# Ctrl+Left -> move backward one word (^[[1;5D is the terminal escape code)
bindkey '^[[1;5D' backward-word

# Ctrl+F -> fzf file picker (no hidden files)
bindkey '^F' _fzf_file_no_hidden

# Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
bindkey '^\' autosuggest-toggle

# History search is atuin's job (^R in insert mode, Up by default). fzf's
# key-bindings.zsh also binds ^R in vi normal mode; restore zsh's redo there.
bindkey -M vicmd '^R' redo
