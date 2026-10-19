# AGENTS.md

Personal Linux (Hyprland/Wayland) dotfiles. Config only: no build, test, lint, or CI. Do not invent `npm`/`make`/test commands.

## Structure & install

- Each top-level dir (`hypr`, `kitty`, `leaf`, `nvim`, `waybar`, `wal`, `walker`, `swaync`, `btop`, `fastfetch`, `mpd`, `rmpc`, `yazi`, `noctalia`, `zen`, `zsh`) is a GNU Stow package containing `.config/<app>`. Install/refresh: `cd ~/dotfiles && stow <pkg> [<pkg>...]`.
- The zsh config is the **`zsh` stow package** (`.config/zsh`), i.e. `~/.config/zsh -> ~/dotfiles/zsh/.config/zsh`. `ZDOTDIR` is `~/.config/zsh` (set in `/etc/zsh/zshenv`); there is no `~/.zshrc`. The `.zshrc` sources the sibling `*.zsh` files from `$ZDOTDIR`.
- The `zsh` package's `plugins/` dir is populated automatically at shell start by `_zplugin_load` in `plugins.zsh` (four third-party repos), so it is **gitignored** — never commit it. Re-clone from scratch by deleting `~/.config/zsh/plugins/`.
- In this checkout the config dirs are already stowed symlinks (`~/.config/<app> -> ~/dotfiles/<app>/.config/<app>`), so repo edits take effect immediately. Re-run `stow` only when adding/removing files or new packages.
- Root `.gitignore` excludes Noctalia-generated theme outputs — the `leaf` user template (`leaf/.config/leaf/noctalia.toml`) plus the builtin/community outputs (`btop/.config/btop/themes/noctalia.theme`, `hypr/.config/hypr/noctalia.lua`, `kitty/.config/kitty/themes/noctalia.conf`, `zsh/.config/zsh/starship.toml`, `fastfetch/.config/fastfetch/themes/noctalia.jsonc`, `yazi/.config/yazi/flavors/noctalia.yazi/{flavor.toml,tmtheme.xml}`) — and the zsh package's auto-cloned plugins and compinit cache (`zsh/.config/zsh/plugins/`, `zsh/.config/zsh/.zcompdump*`). These files still exist on disk (Noctalia rewrites them); they are untracked, not deleted.

## Theming (Noctalia) — the main cross-cutting concern

- All theming is driven by **Noctalia**; its config is the `noctalia` package (`noctalia/.config/noctalia/`). `theme.toml` sets the mode and the `[theme.templates]` lists (`builtin_ids`, `community_ids`, `user.*`), plus the wallpaper directory; the other `*.toml` files configure the bar, widgets, keybinds, etc.
- `hypr/.config/hypr/hyprland.lua` calls `require("noctalia").apply_theme()`, and `autostart.lua` launches `noctalia`. On theme/wallpaper change Noctalia renders its **templates** into per-app **outputs**.
- Outputs that land inside stow packages are generated and gitignored — never edit or commit them: `btop/.config/btop/themes/noctalia.theme`, `hypr/.config/hypr/noctalia.lua`, `kitty/.config/kitty/themes/noctalia.conf`, `fastfetch/.config/fastfetch/themes/noctalia.jsonc`, `yazi/.config/yazi/flavors/noctalia.yazi/{flavor.toml,tmtheme.xml}`, and `zsh/.config/zsh/starship.toml` (the starship output lands in the repo only because `STARSHIP_CONFIG` points at `$ZDOTDIR`). Other outputs (gtk/qt, …) are written straight into `~/.config`/`~/.cache`, outside the repo.
- Template sources live outside the repo: builtins in `/usr/share/noctalia/assets/templates/`, community templates cached in `~/.local/state/noctalia/community-templates/`. To enable one, add it to `theme.toml` — don't vendor templates here.
- Apps with no builtin use a **user template** declared in `theme.toml`: `user.leaf` renders `leaf/.config/leaf/noctalia-{dark,light}.toml.template` → `~/.config/leaf/noctalia.toml` (leaf's `theme`), and `user.obsidian_extra` renders `noctalia/.config/noctalia/Obsidian/obsidian.css` → an Obsidian vault snippet. Those `.template`/`.css` inputs **are** tracked; their rendered outputs are not.
- Apply manually with `noctalia msg templates-apply`. Don't hardcode palette colors in app configs — consume Noctalia's generated output instead.
- **Legacy (pywal)**: `wal`, `waybar`, `swaync`, and `walker` are still stowed but unused (autostarts commented out in `autostart.lua`). `wal`'s templates (`wal/.config/wal/templates/*`) and the `~/.cache/wal` imports are dead — kept for reference only.

## Hyprland

- Configured in **Lua**, not hyprlang. `hypr/.config/hypr/hyprland.lua` `dofile`s `modules/*.lua` in a fixed order; globals defined in `variables.lua` (`Terminal`, `FileManager`, `Menu`) are used by later modules.
- Use the `hl.*` API (`hl.config`, `hl.bind`, `hl.monitor`, `hl.animation`, `hl.on`, ...). Editor stubs: `/usr/share/hypr/stubs/hl.meta.lua` (see `.luarc.json`). `hyprlock.conf` is still hyprlang.
- Apply changes with `hyprctl reload`. `scripts/performance-toggle.sh` toggles animations/blur at runtime.

## Neovim

- Uses Neovim's built-in `vim.pack` (recent Neovim with `vim._core.ui2`), **not** lazy.nvim. Plugins are declared in `lua/config/plugins.lua` and required in `init.lua`; `nvim-pack-lock.json` is the lockfile — commit it when adding/updating plugins (`:lua vim.pack.update()`).
- Format Lua with StyLua using `nvim/.config/nvim/.stylua.toml` (2-space, column width 160, `AutoPreferSingle`, no call parentheses). `conform.nvim` autoformats Python on save (`isort`+`black`) only.

## Waybar

- `config.jsonc` + `style.css`. **Legacy** — no longer launched (see Theming); kept for reference.

## Gotchas

- Scripts referenced by configs live **outside this repo** and are not version-controlled: `~/.local/bin/{setwal,waybar-reload,powermenu,eject-storage.sh}` and `~/scripts/pywal16`. Don't expect to find or edit them here.
- Many values (monitor names, `HDMI-A-1`/`eDP-2`, paths, VRR) are machine-specific; keep them, don't "genericize".
- Commits go directly to `main`; no branch/PR workflow.
