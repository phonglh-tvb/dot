require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "LSP toggle inlay hints" })

map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "telescope document symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "telescope workspace symbols" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "telescope diagnostics" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
