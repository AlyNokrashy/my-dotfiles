require('blink.cmp').setup {
  keymap = {
    -- All presets have the following mappings:
    -- <tab>/<s-tab>: move to right/left of your snippet expansion
    -- <c-space>: Open menu or open docs if already open
    -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
    -- <c-e>: Hide menu
    -- <c-k>: Toggle signature help
    preset = 'default',
  },
  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    nerd_font_variant = 'mono',
  },

  completion = {
    -- nvim-highlight-colors integration
    menu = {
      draw = {
        components = {
          -- customize the drawing of kind icons
          kind_icon = {
            text = function(ctx)
              -- default kind icon
              local icon = ctx.kind_icon
              -- if LSP source, check for color derived from documentation
              if ctx.item.source_name == 'LSP' then
                local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                if color_item and color_item.abbr ~= '' then icon = color_item.abbr end
              end
              return icon .. ctx.icon_gap
            end,
            highlight = function(ctx)
              -- default highlight group
              local highlight = 'BlinkCmpKind' .. ctx.kind
              -- if LSP source, check for color derived from documentation
              if ctx.item.source_name == 'LSP' then
                local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                if color_item and color_item.abbr_hl_group then highlight = color_item.abbr_hl_group end
              end
              return highlight
            end,
          },
        },
      },
    },
    -- By default, you may press `<c-space>` to show the documentation.
    -- Optionally, set `auto_show = true` to show the documentation after a delay.
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },

  snippets = { preset = 'luasnip' },

  fuzzy = { implementation = 'lua' },

  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },
}
