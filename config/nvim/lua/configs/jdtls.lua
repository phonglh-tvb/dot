-- Cấu hình nvim-jdtls (plugins/java.lua gọi start() cho mỗi buffer java)
local M = {}

local function mason(path)
  return vim.fn.stdpath "data" .. "/mason/packages/" .. path
end

-- JDK do mise cài: { major = 21, path = "..." }, bỏ symlink trùng
local function installed_jdks()
  local base = vim.fn.expand "~/.local/share/mise/installs/java"
  local jdks, seen = {}, {}
  for name in vim.fs.dir(base) do
    local major = tonumber(name:match "(%d+)")
    local path = major and vim.uv.fs_realpath(base .. "/" .. name)
    if path and not seen[path] and vim.uv.fs_stat(path .. "/bin/java") then
      seen[path] = true
      table.insert(jdks, { major = major, path = path })
    end
  end
  table.sort(jdks, function(a, b)
    return a.major < b.major
  end)
  return jdks
end

local function bundles()
  local jars = vim.fn.glob(mason "java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
  local skip = { ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true, ["jacocoagent.jar"] = true }
  for _, jar in ipairs(vim.fn.glob(mason "java-test/extension/server/*.jar", true, true)) do
    if not skip[vim.fs.basename(jar)] then
      table.insert(jars, jar)
    end
  end
  return jars
end

local function on_attach(_, bufnr)
  local jdtls = require "jdtls"

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Java " .. desc })
  end

  map("n", "<leader>jo", jdtls.organize_imports, "organize imports")
  map("n", "<leader>jv", jdtls.extract_variable, "extract variable")
  map("x", "<leader>jv", function()
    jdtls.extract_variable(true)
  end, "extract variable")
  map("n", "<leader>jc", jdtls.extract_constant, "extract constant")
  map("x", "<leader>jc", function()
    jdtls.extract_constant(true)
  end, "extract constant")
  map("x", "<leader>jm", function()
    jdtls.extract_method(true)
  end, "extract method")
  map("n", "<leader>jt", jdtls.test_class, "test class")
  map("n", "<leader>jn", jdtls.test_nearest_method, "test nearest method")

  jdtls.setup_dap { hotcodereplace = "auto" }
  require("jdtls.dap").setup_dap_main_class_configs()
end

function M.start()
  local jdtls = require "jdtls"

  local root = vim.fs.root(0, {
    "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", "pom.xml", "build.gradle", "build.gradle.kts", ".git",
  }) or vim.fn.getcwd()

  -- jdtls bản mới đòi JDK mới nhất (hiện là 25) để chạy, độc lập với JDK mà project build
  local jdks = installed_jdks()
  local runner = jdks[#jdks]
  local runtimes = {}
  for _, jdk in ipairs(jdks) do
    table.insert(runtimes, {
      name = jdk.major == 8 and "JavaSE-1.8" or ("JavaSE-" .. jdk.major),
      path = jdk.path,
    })
  end

  local workspace = ("%s/jdtls/%s-%s"):format(vim.fn.stdpath "cache", vim.fs.basename(root), vim.fn.sha256(root):sub(1, 8))
  local cmd = { "jdtls", "-data", workspace }
  local lombok = mason "jdtls/lombok.jar"
  if vim.uv.fs_stat(lombok) then
    table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
  end

  local capabilities = vim.tbl_deep_extend("force", {}, require("nvchad.configs.lspconfig").capabilities)

  jdtls.start_or_attach {
    name = "jdtls",
    cmd = cmd,
    cmd_env = runner and { JAVA_HOME = runner.path } or nil,
    root_dir = root,
    capabilities = capabilities,
    on_attach = on_attach,
    init_options = {
      bundles = bundles(),
      extendedClientCapabilities = vim.tbl_extend("force", jdtls.extendedClientCapabilities, {
        resolveAdditionalTextEditsSupport = true,
      }),
    },
    settings = {
      java = {
        configuration = { runtimes = runtimes },
        signatureHelp = { enabled = true },
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        references = { includeDecompiledSources = true },
        inlayHints = { parameterNames = { enabled = "literals" } },
      },
    },
  }
end

return M
