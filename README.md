## Installation

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
stow btop fastfetch hypr kitty mpd noctalia nvim rmpc swaync wal walker waybar yazi
ln -sf ~/dotfiles/.zshrc ~/.zshrc
```

Then generate theme colors (requires pywal / your `setwal` wrapper):

```bash
wal -R
```

External, un-versioned requirements (not in this repo): `~/.local/bin/{setwal,waybar-reload,powermenu,eject-storage.sh}`, `~/scripts/pywal16`, plus oh-my-zsh + powerlevel10k, zoxide, and the leaf completions referenced by `.zshrc`.
