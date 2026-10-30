-- Rust: rustaceanvim tự cấu hình codelldb; Java: nvim-jdtls (configs/jdtls.lua)
local dap = require "dap"
local dapui = require "dapui"

dapui.setup()
require("nvim-dap-virtual-text").setup()

dap.listeners.after.event_initialized["dapui"] = dapui.open
dap.listeners.before.event_terminated["dapui"] = dapui.close
dap.listeners.before.event_exited["dapui"] = dapui.close

require("dap-go").setup()
require("dap-python").setup(vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python")

-- JS / TS / Chrome qua js-debug-adapter (mason)
for _, type in ipairs { "pwa-node", "pwa-chrome" } do
  dap.adapters[type] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = "js-debug-adapter", args = { "${port}" } },
  }
end

local js_configs = {
  { type = "pwa-node", request = "launch", name = "Node: launch file", program = "${file}", cwd = "${workspaceFolder}" },
  { type = "pwa-node", request = "attach", name = "Node: attach to process", processId = require("dap.utils").pick_process, cwd = "${workspaceFolder}" },
  { type = "pwa-chrome", request = "launch", name = "Chrome: localhost:3000", url = "http://localhost:3000", webRoot = "${workspaceFolder}" },
}

for _, ft in ipairs { "javascript", "typescript", "javascriptreact", "typescriptreact" } do
  dap.configurations[ft] = js_configs
end
