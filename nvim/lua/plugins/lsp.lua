-- Extend LazyVim's mason config with a preferred LSP server list.
-- Actual server installs happen via :Mason UI; this just makes mason aware.
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "prettier",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {},
        ts_ls = {},
        gopls = {},
        pyright = {},
        rust_analyzer = {},
        bashls = {},
      },
    },
  },
}
