vim.pack.add {
  {
    src = 'https://github.com/obsidian-nvim/obsidian.nvim',
    version = vim.version.range '*', -- use latest release, remove to use latest commit
  },
}

require('obsidian').setup {
  legacy_commands = false,
  workspaces = {
    {
      name = 'personal',
      path = '~/Documents/Obsidian/My Vault',
      strict = true,
    },
  },
  new_notes_location = 'notes_subdir',
  notes_subdir = 'Zettelkasten',
  templates = {
    folder = 'Templates',
    date_format = '%Y-%m-%d-%a',
    time_format = '%H:%M',
    substitutions = {},
    -- customizations = {},
  },
  frontmatter = {
    enabled = true,

    func = function(note)
      local out = {
        id = note.id,
        aliases = note.aliases,
        tags = note.tags,
      }

      if note.metadata then out = vim.tbl_extend('force', out, note.metadata) end

      out.type = out.type or 'concept'
      out.created = out.created or os.date '%Y-%m-%d'

      return out
    end,

    sort = {
      'id',
      'aliases',
      'type',
      'course',
      'semester',
      'tags',
      'created',
    },
  },
  note_id_func = function(title)
    if title then
      return title
        :gsub('%s+', '-') -- spaces -> -
        :gsub('[^%w%-]', '') -- remove punctuation
        :lower() -- optional
    end

    return tostring(os.time())
  end,
}
