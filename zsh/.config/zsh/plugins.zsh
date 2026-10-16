# =========================================================
# Plugins
# =========================================================

# Guard: re-sourcing .zshrc must NOT reload the plugins. Plugins like
# zsh-autosuggestions and fast-syntax-highlighting re-wrap ZLE widgets on
# every source; loading them twice makes the wrappers call themselves and
# you get "maximum nested function level reached; increase FUNCNEST?".
# Use `exec zsh` to pick up plugin changes instead of sourcing.
(( ${+_ZSH_PLUGINS_LOADED} )) && return
typeset -g _ZSH_PLUGINS_LOADED=1

ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load jeffreytse zsh-vi-mode
_zplugin_load zdharma-continuum fast-syntax-highlighting
