return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    opts = {
        legacy_commands = false,
        note_id_func = function(title)
            if title ~= nil then
                return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
                return tostring(os.time())
            end
        end,
        frontmatter = {
            enabled = false,
        },
        note = {
            template = "minimal.md",
        },
        workspaces = {
            {
                name = "personal",
                path = "~/Documents/Obsidian/My Vault/",
            },

            {
                name = "test",
                path = "~/Documents/Obsidian/New Vault/",
            },
        },

        notes_subdir = "Zettelkasten",
        new_notes_location = "notes_subdir",

        picker = {
            name = "snacks.picker",
        },
        templates = {
            folder = "Templates",
        },
        preffered_link_style = "wiki",
    },
}
