-- Dùng cho vim.g.rustaceanvim (plugins.lua)
return {
  server = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    default_settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true, loadOutDirsFromCheck = true },
        check = { command = "clippy" },
        procMacro = { enable = true },
      },
    },
    on_attach = function(_, bufnr)
      local function map(lhs, cmd, desc)
        vim.keymap.set("n", lhs, function()
          vim.cmd.RustLsp(cmd)
        end, { buf = bufnr, desc = "Rust " .. desc })
      end

      map("<leader>rr", "runnables", "runnables")
      map("<leader>rt", "testables", "testables")
      map("<leader>rd", "debuggables", "debuggables")
      map("<leader>re", "expandMacro", "expand macro")
      map("<leader>rx", "explainError", "explain error")
      map("<leader>rc", "openCargo", "open Cargo.toml")
      map("<leader>rp", "parentModule", "parent module")
      map("<leader>rj", "joinLines", "join lines")
      map("K", { "hover", "actions" }, "hover actions")
    end,
  },
}
