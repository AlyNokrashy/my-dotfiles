 local M = {}

 function M.setup()
   require('base16-colorscheme').setup {
     -- Background tones
     base00 = '#1d2021', -- Default Background
     base01 = '#282828', -- Lighter Background (status bars)
     base02 = '#323232', -- Selection Background
     base03 = '#6a6a6a', -- Comments, Invisibles
     -- Foreground tones
     base04 = '#d4be98', -- Dark Foreground (status bars)
     base05 = '#d4be98', -- Default Foreground
     base06 = '#d4be98', -- Light Foreground
     base07 = '#d4be98', -- Lightest Foreground
     -- Accent colors
     base08 = '#ea6962', -- Variables, XML Tags, Errors
     base09 = '#89b482', -- Integers, Constants
     base0A = '#e78a4e', -- Classes, Search Background
     base0B = '#a9b665', -- Strings, Diff Inserted
     base0C = '#a1e996', -- Regex, Escape Chars
     base0D = '#dbe996', -- Functions, Methods
     base0E = '#f0b58f', -- Keywords, Storage
     base0F = '#8a160f', -- Deprecated, Embedded Tags
   }
 end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
    vim.schedule_wrap(function()
      package.loaded['plugins.matugen'] = nil
      require('plugins.matugen')
    end)
  )

  M.setup()

  return M
