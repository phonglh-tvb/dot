local function dap(fn, ...)
  local args = { ... }
  return function()
    require("dap")[fn](unpack(args))
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<leader>db", dap "toggle_breakpoint", desc = "Debug toggle breakpoint" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input "Condition: ")
        end,
        desc = "Debug conditional breakpoint",
      },
      { "<leader>dc", dap "continue", desc = "Debug continue" },
      { "<leader>di", dap "step_into", desc = "Debug step into" },
      { "<leader>do", dap "step_over", desc = "Debug step over" },
      { "<leader>dO", dap "step_out", desc = "Debug step out" },
      { "<leader>dl", dap "run_last", desc = "Debug run last" },
      { "<leader>dt", dap "terminate", desc = "Debug terminate" },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Debug REPL",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug UI",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "x" },
        desc = "Debug eval",
      },
    },
    config = function()
      require "configs.dap"
    end,
  },
}
