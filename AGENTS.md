# AGENTS.md

Personal Linux (Hyprland/Wayland) dotfiles. Config only: no build, test, lint, or CI. Do not invent `npm`/`make`/test commands.

## Structure & install

- Each top-level dir (`hypr`, `kitty`, `leaf`, `nvim`, `waybar`, `wal`, `walker`, `swaync`, `btop`, `fastfetch`, `mpd`, `rmpc`, `yazi`, `noctalia`) is a GNU Stow package containing `.config/<app>`. Install/refresh: `cd ~/dotfiles && stow <pkg> [<pkg>...]`.
- `.zshrc` at the repo root is **not** a stow package; it is symlinked manually to `~/.zshrc`. Editing it in the repo is correct.
- In this checkout the config dirs are already stowed symlinks (`~/.config/<app> -> ~/dotfiles/<app>/.config/<app>`), so repo edits take effect immediately. Re-run `stow` only when adding/removing files or new packages.
- Root `.gitignore` only excludes Noctalia-generated files (currently `leaf/.config/leaf/noctalia.toml`).

## Theming (pywal) — the main cross-cutting concern

- Theme templates live in `wal/.config/wal/templates/`. `wal` renders them into `~/.cache/wal/`, and apps import the **generated cache files** using hardcoded absolute paths (`/home/aly/.cache/wal/...`), not the templates.
- To change colors: edit the template, then regenerate with `wal -R` (or the external `setwal`). Available placeholders: `{background}`, `{foreground}`, `{cursor}`, `{color0}`..`{color15}`, `{wallpaper}`.
- Consumers: waybar `style.css` and swaync `style.css` import `colors-waybar.css`; `hypr/modules/appearance.lua` loads `colors-hyprland.lua`; hyprlock sources `colors-hypr.conf`; walker imports `walker-colors.css`; rmpc uses the generated `rmpc.ron`. Some custom templates (e.g. `waybar.css`, `swaync.css`) are rendered but not currently imported — check the consumer before assuming a template is live.
- Keep the `/home/aly` absolute-path convention when adding imports, and don't hardcode palette colors in app configs.

## Hyprland

- Configured in **Lua**, not hyprlang. `hypr/.config/hypr/hyprland.lua` `dofile`s `modules/*.lua` in a fixed order; globals defined in `variables.lua` (`Terminal`, `FileManager`, `Menu`) are used by later modules.
- Use the `hl.*` API (`hl.config`, `hl.bind`, `hl.monitor`, `hl.animation`, `hl.on`, ...). Editor stubs: `/usr/share/hypr/stubs/hl.meta.lua` (see `.luarc.json`). `hyprlock.conf` is still hyprlang.
- Apply changes with `hyprctl reload`. `scripts/performance-toggle.sh` toggles animations/blur at runtime.

## Neovim

- Uses Neovim's built-in `vim.pack` (recent Neovim with `vim._core.ui2`), **not** lazy.nvim. Plugins are declared in `lua/config/plugins.lua` and required in `init.lua`; `nvim-pack-lock.json` is the lockfile — commit it when adding/updating plugins (`:lua vim.pack.update()`).
- Format Lua with StyLua using `nvim/.config/nvim/.stylua.toml` (2-space, column width 160, `AutoPreferSingle`, no call parentheses). `conform.nvim` autoformats Python on save (`isort`+`black`) only.

## Waybar

- `config.jsonc` + `style.css`.

## Gotchas

- Scripts referenced by configs live **outside this repo** and are not version-controlled: `~/.local/bin/{setwal,waybar-reload,powermenu,eject-storage.sh}` and `~/scripts/pywal16`. Don't expect to find or edit them here.
- Many values (monitor names, `HDMI-A-1`/`eDP-2`, paths, VRR) are machine-specific; keep them, don't "genericize".
- Commits go directly to `main`; no branch/PR workflow.
