return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            hint = {
                                enable = true,
                            },
                            runtime = {
                                version = "LuaJIT",
                            },
                            workspace = {
                                checkThirdParty = true,
                                library = {
                                    vim.env.VIMRUNTIME,
                                    vim.fn.expand("~/.local/share/nvim/lazy/solarized.nvim"),
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}
