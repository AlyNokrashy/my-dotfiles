# =========================================================
# Keybindings
# =========================================================

# zsh-vi-mode settings MUST go in zvm_config(), not at the top level.
# This file is sourced BEFORE plugins.zsh loads zsh-vi-mode, so the
# $ZVM_CURSOR_* constants do not exist yet and a top-level assignment
# would set an empty value that the plugin then overwrites with its
# default. zsh-vi-mode calls zvm_config() (its ZVM_CONFIG_FUNC) after
# it has defined those constants.
zvm_config() {
  # Cursor shape per vi mode
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

  # Disable command mode line highlight
  ZVM_VI_HIGHLIGHT_BACKGROUND=none
  ZVM_VI_HIGHLIGHT_FOREGROUND=none
  ZVM_VI_HIGHLIGHT_EXTRASTYLE=none
}

# zsh-vi-mode resets all bindings on init, so custom bindings
# must be registered via this hook to survive.
zvm_after_init() {
  # Ctrl+Right -> move forward one word (^[[1;5C is the terminal escape code)
  bindkey '^[[1;5C' forward-word

  # Ctrl+Left -> move backward one word (^[[1;5D is the terminal escape code)
  bindkey '^[[1;5D' backward-word

  # Ctrl+F -> fzf file picker (no hidden files)
  bindkey '^F' _fzf_file_no_hidden

  # Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
  bindkey '^\' autosuggest-toggle

  # Up/Down -> history search by substring (^[[A/^[[B are up/down arrow escape codes)
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}
