return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("jdtls", { clear = true }),
        pattern = "java",
        callback = function()
          require("configs.jdtls").start()
        end,
      })
      -- buffer java đầu tiên đã bắn FileType trước khi plugin load
      require("configs.jdtls").start()
    end,
  },
}
