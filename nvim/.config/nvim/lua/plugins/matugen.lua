 local M = {}

 function M.setup()
   require('base16-colorscheme').setup {
     -- Background tones
     base00 = '#1a2023', -- Default Background
     base01 = '#2b353b', -- Lighter Background (status bars)
     base02 = '#262f36', -- Selection Background
     base03 = '#616b71', -- Comments, Invisibles
     -- Foreground tones
     base04 = '#afb3b6', -- Dark Foreground (status bars)
     base05 = '#f2f2f3', -- Default Foreground
     base06 = '#f2f2f3', -- Light Foreground
     base07 = '#f2f2f3', -- Lightest Foreground
     -- Accent colors
     base08 = '#fd4663', -- Variables, XML Tags, Errors
     base09 = '#9278ba', -- Integers, Constants
     base0A = '#787eba', -- Classes, Search Background
     base0B = '#89abc2', -- Strings, Diff Inserted
     base0C = '#bbabd4', -- Regex, Escape Chars
     base0D = '#abc3d4', -- Functions, Methods
     base0E = '#abaed4', -- Keywords, Storage
     base0F = '#741d2b', -- Deprecated, Embedded Tags
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
