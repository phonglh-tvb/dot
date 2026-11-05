-- Rust: rustaceanvim tự cấu hình codelldb; Java: nvim-jdtls (configs/jdtls.lua)
local M = {}

local function csproj_root()
  return vim.fs.root(0, function(name)
    return name:match "%.csproj$" ~= nil
  end)
end

-- Build rồi trả về dll của project (chặn giao diện vài giây, nvim-dap cần đường dẫn ngay); bản TFM mới nhất xếp cuối
local function dotnet_dll()
  local root = csproj_root()
  local project = root and vim.fn.glob(root .. "/*.csproj", false, true)[1]
  if not project then
    vim.notify("Không thấy .csproj quanh file này", vim.log.levels.ERROR)
    return require("dap").ABORT
  end

  local build = vim.system({ "dotnet", "build", project }, { text = true }):wait()
  if build.code ~= 0 then
    vim.notify(build.stdout, vim.log.levels.ERROR, { title = "dotnet build" })
    return require("dap").ABORT
  end

  local dlls = vim.fn.glob(root .. "/bin/Debug/*/" .. vim.fn.fnamemodify(project, ":t:r") .. ".dll", false, true)
  return dlls[#dlls] or require("dap").ABORT
end

function M.setup()
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
    {
      type = "pwa-node",
      request = "launch",
      name = "Node: launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Node: attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Chrome: localhost:3000",
      url = "http://localhost:3000",
      webRoot = "${workspaceFolder}",
    },
  }

  for _, ft in ipairs { "javascript", "typescript", "javascriptreact", "typescriptreact" } do
    dap.configurations[ft] = js_configs
  end

  -- C#: netcoredbg cài bằng mise (bản có osx-arm64; Mason chỉ có bản x86_64, không debug được app arm64)
  dap.adapters.coreclr = { type = "executable", command = "netcoredbg", args = { "--interpreter=vscode" } }
  dap.configurations.cs = {
    {
      type = "coreclr",
      request = "launch",
      name = "C#: build and launch",
      program = dotnet_dll,
      cwd = csproj_root,
      env = { ASPNETCORE_ENVIRONMENT = "Development" },
    },
    {
      type = "coreclr",
      request = "attach",
      name = "C#: attach to process",
      processId = require("dap.utils").pick_process,
    },
  }
end

return M
