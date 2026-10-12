# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# add cargo packages to PATH
export PATH="$HOME/.cargo/bin:$PATH"
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-system-clipboard
        history)

source $ZSH/oh-my-zsh.sh

# pywal colors
source ~/.cache/wal/colors.sh

# zoxide
eval "$(zoxide init zsh --cmd cd)"
# eval "$(starship init zsh)"


# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# vi mode
bindkey -v

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
# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

export EDITOR='nvim'
export VISUAL="nvim"
export SYSTEMD_EDITOR="nvim"

export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='bat -p --color=always {}'"

# colored man pages
export MANROFFOPT="-c"

export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'

export MANPAGER="less -R"


export QT_QPA_PLATFORMTHEME=qt6ct


# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias c="clear"
alias v="nvim"
alias vo='NVIM_APPNAME="nvim-old" nvim'

alias tux="tuxedo"

alias steam="prime-run steam"

# advances mv and cp
alias cp="/usr/local/bin/advcp -g"
alias mv="/usr/local/bin/advmv -g"

alias lss="eza --color=always --long --git --no-filesize --no-user --no-time --no-permissions --grid"

alias stremio="flatpak run com.stremio.Stremio --no-window-decorations >/dev/null 2>&1 & disown"

alias g++="g++ -std=c++17 -Wall -Wextra"


# opencode
export PATH="$HOME/.opencode/bin:$PATH"
[[ -f "$HOME/.local/share/leaf/completions/_leaf" ]] && source "$HOME/.local/share/leaf/completions/_leaf"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
