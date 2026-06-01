return {
    {
        "catppuccin/nvim",
        lazy = true,
        name = "catppuccin",
        opts = {
            flavor = "mocha",
            lsp_styles = {
                underlines = {
                    errors = { "undercurl" },
                    hints = { "undercurl" },
                    warnings = { "undercurl" },
                    information = { "undercurl" },
                },
            },
            integrations = {
                aerial = true,
                alpha = true,
                cmp = true,
                dashboard = true,
                flash = true,
                fzf = true,
                grug_far = true,
                gitsigns = true,
                headlines = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                leap = true,
                lsp_trouble = true,
                mason = true,
                mini = true,
                navic = { enabled = true, custom_bg = "lualine" },
                neotest = true,
                neotree = true,
                noice = true,
                notify = true,
                snacks = true,
                telescope = true,
                treesitter_context = true,
                which_key = true,
            },
        },
        specs = {
            {
                "akinsho/bufferline.nvim",
                optional = true,
                opts = function(_, opts)
                    if (vim.g.colors_name or ""):find("catppuccin") then
                        opts.highlights = require("catppuccin.special.bufferline").get_theme()
                    end
                end,
            },
        },
    },
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        priority = 1000,
        config = function()
            vim.o.termguicolors = true
            vim.o.background = "dark"

            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_foreground = "material"
            vim.g.gruvbox_material_enable_italic = 1
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_better_performance = 1
            -- vim.g.gruvbox_material_visual = "red background"
            vim.g.gruvbox_material_ui_contrast = "high"
            vim.g.gruvbox_material_float_style = "dim"
            vim.g.gruvbox_material_show_eob = 0
        end,
    },
    {
        "maxmx03/solarized.nvim",
        lazy = true,
        priority = 1000,
        opts = {},
        config = function(_, opts)
            vim.o.termguicolors = true
            vim.o.background = "light"

            require("solarized").setup(opts)
        end,
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "gruvbox-material",
        },
    },
}
