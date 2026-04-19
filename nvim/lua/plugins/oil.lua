-- oil.nvim — edit your filesystem like a buffer. Complements the default
-- neo-tree (kept for sidebar browsing).
return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      default_file_explorer = false,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["q"] = "actions.close",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent dir (oil)" },
      { "<leader>fo", "<cmd>Oil<cr>", desc = "Open oil (buffer-as-dir)" },
    },
  },
}
