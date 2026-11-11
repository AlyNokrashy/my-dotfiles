# =========================================================
# Keybindings
# =========================================================

# Emacs-style keymaps. Selected explicitly because this zsh otherwise starts
# with 'main' linked to viins, i.e. vi editing on by default. Must come before
# the bindings below, which are made without -M and land in the active keymap.
bindkey -e

# Ctrl+Right -> move forward one word (^[[1;5C is the terminal escape code)
bindkey '^[[1;5C' forward-word

# Ctrl+Left -> move backward one word (^[[1;5D is the terminal escape code)
bindkey '^[[1;5D' backward-word

# Ctrl+F -> fzf file picker (no hidden files)
bindkey '^F' _fzf_file_no_hidden

# Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
bindkey '^\' autosuggest-toggle

# History search is atuin's job (^R, Up by default).
