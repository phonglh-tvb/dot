local map = vim.keymap.set

---------------------------------- mặc định của NvChad v2.5 ----------------------------------
-- (chép lại từ nvchad/mappings.lua để giữ nguyên thói quen)
map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

map({ "n", "x" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- tabufline
if require("nvconfig").ui.tabufline.enabled then
  map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

  map("n", "<tab>", function()
    require("nvchad.tabufline").next()
  end, { desc = "buffer goto next" })

  map("n", "<S-tab>", function()
    require("nvchad.tabufline").prev()
  end, { desc = "buffer goto prev" })

  map("n", "<leader>x", function()
    require("nvchad.tabufline").close_buffer()
  end, { desc = "buffer close" })
end

-- Comment (gc gốc của Neovim)
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

map("n", "<leader>th", function()
  require("nvchad.themes").open()
end, { desc = "telescope nvchad themes" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- new terminals
map("n", "<leader>h", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "terminal new horizontal term" })

map("n", "<leader>v", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "terminal new vertical term" })

-- toggleable
map({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "terminal toggleable vertical term" })

map({ "n", "t" }, "<A-h>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggleable horizontal term" })

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

---------------------------------- của bạn ----------------------------------
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "LSP toggle inlay hints" })

map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "telescope document symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "telescope workspace symbols" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "telescope diagnostics" })

-- Danh sách diagnostics / references / symbols bằng quickfix gốc (thay trouble.nvim)
map("n", "<leader>qd", function()
  vim.diagnostic.setqflist()
end, { desc = "quickfix diagnostics (workspace)" })
map("n", "<leader>qb", vim.diagnostic.setloclist, { desc = "loclist diagnostics (buffer)" })
map("n", "<leader>qr", vim.lsp.buf.references, { desc = "quickfix LSP references" })
map("n", "<leader>qs", vim.lsp.buf.document_symbol, { desc = "loclist LSP document symbols" })
map("n", "<leader>ql", "<cmd>copen<cr>", { desc = "open quickfix" })

-- Debug
local function dap(fn, ...)
  local args = { ... }
  return function()
    require("dap")[fn](unpack(args))
  end
end

map("n", "<leader>db", dap "toggle_breakpoint", { desc = "Debug toggle breakpoint" })
map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input "Condition: ")
end, { desc = "Debug conditional breakpoint" })
map("n", "<leader>dc", dap "continue", { desc = "Debug continue" })
map("n", "<leader>di", dap "step_into", { desc = "Debug step into" })
map("n", "<leader>do", dap "step_over", { desc = "Debug step over" })
map("n", "<leader>dO", dap "step_out", { desc = "Debug step out" })
map("n", "<leader>dl", dap "run_last", { desc = "Debug run last" })
map("n", "<leader>dt", dap "terminate", { desc = "Debug terminate" })
map("n", "<leader>dr", function()
  require("dap").repl.toggle()
end, { desc = "Debug REPL" })
map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug UI" })
map({ "n", "x" }, "<leader>de", function()
  require("dapui").eval()
end, { desc = "Debug eval" })

-- Completion gốc: Tab / S-Tab chọn mục hoặc nhảy trong snippet, <C-Space> gọi tay, <CR> do nvim-autopairs lo
map("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet.active { direction = 1 } then
    vim.schedule(function()
      vim.snippet.jump(1)
    end)
    return ""
  end
  return "<Tab>"
end, { expr = true, desc = "completion next / snippet jump" })

map("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet.active { direction = -1 } then
    vim.schedule(function()
      vim.snippet.jump(-1)
    end)
    return ""
  end
  return "<S-Tab>"
end, { expr = true, desc = "completion prev / snippet jump back" })

map("i", "<C-Space>", function()
  vim.lsp.completion.get()
end, { desc = "LSP trigger completion" })
