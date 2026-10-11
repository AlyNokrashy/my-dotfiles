# Adding Plugins (vim.pack)

This config uses Neovim's built-in `vim.pack`, **not** lazy.nvim/plug. There are two
separate things you can do to a plugin, and they are independent:

1. **Declare** it in `lua/config/plugins.lua` — makes Neovim install it and put it on
   `runtimepath`.
2. **Require** a setup file in `init.lua` — runs *your* Lua code that configures it.

Declaring does **not** load a setup file. Requiring does **not** install anything.
A plugin can be declared but never required (always the case for colorschemes, since
you activate those with `:colorscheme`, and for plugins that work with zero config).

---

## Step-by-step

### 1. Declare it

Open `lua/config/plugins.lua` and add a line:

```lua
vim.pack.add { 'https://github.com/user/repo' }
```

Notes:

- Use the full GitHub URL. The plugin is installed into
  `~/.local/share/nvim/site/pack/core/opt/<repo-name>`.
- Rename the folder when the repo name is ugly or has dots:
  ```lua
  vim.pack.add { { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' } }
  ```
- Pin a version/tag/branch when the plugin isn't safe to track HEAD:
  ```lua
  vim.pack.add { { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' } }
  vim.pack.add { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }
  ```
- Bundle unrelated plugins in one call if you want (see the lspconfig group at the
  bottom of `lua/config/plugins.lua`).

### 2. Install it

Just **restart Neovim**. `vim.pack.add` installs any missing plugin on startup. You can
also install without restarting by running the same `vim.pack.add{...}` live via
`:lua vim.pack.add { 'https://github.com/user/repo' }`.

### 3. Configure it (only if needed)

If the plugin has a `setup()` or you want to set globals/keymaps, create a file under
`lua/plugins/` whose name matches the module you will `require`:

```lua
-- lua/plugins/<name>.lua
require('<plugin-lua-module>').setup {
  -- options
}
```

Then tell the config to run it by adding to `init.lua` (next to the other `require 'plugins.*'`
lines):

```lua
require 'plugins.<name>'
```

If the plugin needs no configuration, skip this step entirely — declaring is enough.

### 4. Commit the lockfile

`nvim-pack-lock.json` records the exact revision of every plugin. After installing or
updating, commit it so the setup is reproducible:

```
git add nvim/.config/nvim/nvim-pack-lock.json nvim/.config/nvim/lua/config/plugins.lua
```

---

## Declaring vs. requiring — the key difference

| | `vim.pack.add` in `config/plugins.lua` | `require 'plugins.x'` in `init.lua` |
|---|---|---|
| What it does | Installs the repo + adds it to `runtimepath` | Runs your Lua config/`setup()` code |
| Required for the plugin to exist | **Yes** | No |
| Required for default behavior | No | No |
| Runs on every startup | Yes (cheap: just rtp entry) | Only the lines you list in `init.lua` |
| Name source | The repo URL (or `name =`) | The **file path**: `plugins.oil` → `lua/plugins/oil.lua` |

The two names are unrelated. Example from this config:

- Repo `stevearc/oil.nvim` is declared, but you `require 'plugins.oil'`
  (`lua/plugins/oil.lua`), and *inside* that file you call `require('oil').setup {}`.
  So there can be three different names: repo folder `oil.nvim`, your config module
  `plugins.oil`, and the plugin's own Lua module `oil`.

**Why split them?** Declaration is the "shopping list" (what to install). `init.lua` is
the "run order" (what config to execute and in what sequence). This is why a
colorscheme plugin is declared but has no `require` line — you apply it with
`vim.cmd.colorscheme` instead. It's also why removing a `require` line disables a
plugin's customization without uninstalling it.

---

## Removing / updating

- **Remove**: delete the `vim.pack.add` line and run `:lua vim.pack.del { '<name>' }`,
  then remove any leftover `require 'plugins.<name>'` from `init.lua`.
- **Update all**: `:lua vim.pack.update()`
- **Update offline** (use cached, no network): `:lua vim.pack.update(nil, { offline = true })`
- **Health check**: `:checkhealth vim.pack`

---

## Gotchas in this config

- The active colorscheme is dynamic (pywal/matugen → `lua/plugins/matugen.lua` which calls
  `base16-colorscheme`). A static colorscheme will be overridden by it on signal updates.
- `lua/plugins/colorscheme.lua` exists but is **not** required by `init.lua`, so it is
  currently dead code.
- Plugins resolve at startup only from the `require` list in `init.lua`; adding a file
  under `lua/plugins/` does nothing until you `require` it.
