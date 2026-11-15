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

-- đọc code: nhãn TODO trong comment, link GitHub của dòng đang đứng
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "telescope todo comments" })
-- ]n / [n chứ không phải ]t / [t như README của plugin: Neovim 0.12 đã dùng ]t cho :tnext
map("n", "]n", function()
  require("todo-comments").jump_next()
end, { desc = "next todo comment" })
map("n", "[n", function()
  require("todo-comments").jump_prev()
end, { desc = "prev todo comment" })
map("n", "<leader>gl", "<cmd>GitLink<CR>", { desc = "gitlinker copy github link" })
map("n", "<leader>gL", "<cmd>GitLink!<CR>", { desc = "gitlinker open github link" })
-- dùng ":" (không phải <cmd>) để visual mode tự điền '<,'> làm vùng dòng cho GitLink
map("x", "<leader>gl", ":GitLink<CR>", { desc = "gitlinker copy github link for selection" })
map("x", "<leader>gL", ":GitLink!<CR>", { desc = "gitlinker open github link for selection" })

-- gitsigns: nhảy giữa các hunk, xem, stage, blame. Trong diff mode ]c / [c giữ nghĩa gốc của Neovim
map("n", "]c", function()
  if vim.wo.diff then
    vim.cmd.normal { "]c", bang = true }
  else
    require("gitsigns").nav_hunk "next"
  end
end, { desc = "git next hunk" })
map("n", "[c", function()
  if vim.wo.diff then
    vim.cmd.normal { "[c", bang = true }
  else
    require("gitsigns").nav_hunk "prev"
  end
end, { desc = "git prev hunk" })
map("n", "<leader>gp", function()
  require("gitsigns").preview_hunk()
end, { desc = "git preview hunk" })
-- gọi trên hunk đã stage thì bỏ stage
map("n", "<leader>gh", function()
  require("gitsigns").stage_hunk()
end, { desc = "git stage / unstage hunk" })
map("x", "<leader>gh", function()
  require("gitsigns").stage_hunk { vim.fn.line ".", vim.fn.line "v" }
end, { desc = "git stage / unstage selected lines" })
map("n", "<leader>gb", function()
  require("gitsigns").blame_line { full = true }
end, { desc = "git blame line" })
map("n", "<leader>gB", function()
  require("gitsigns").blame()
end, { desc = "git blame buffer" })

-- Chép vị trí để dán vào Claude Code (@path#L42), PR, Jira. Ở visual mode lấy cả khoảng dòng đang chọn;
-- line "v" ngoài visual mode chính là dòng con trỏ.
local function selected_lines()
  local first, last = vim.fn.line "v", vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  return first, last
end

local function copy(text, msg)
  vim.fn.setreg("+", text)
  if vim.fn.mode():find "^[vV\22]" then
    vim.api.nvim_feedkeys(vim.keycode "<Esc>", "nx", false)
  end
  vim.notify(msg or ("đã chép " .. text))
end

local function copy_path(modifier)
  return function()
    local name = vim.api.nvim_buf_get_name(0)
    if name == "" then
      return vim.notify("buffer chưa có tên file", vim.log.levels.WARN)
    end
    local first, last = selected_lines()
    local lines = first == last and ("#L" .. first) or ("#L%d-%d"):format(first, last)
    copy(vim.fn.fnamemodify(name, modifier) .. lines)
  end
end

map({ "n", "x" }, "<leader>yf", copy_path ":.", { desc = "copy relative path with line" })
map({ "n", "x" }, "<leader>yp", copy_path ":p", { desc = "copy absolute path with line" })

-- Vùng chọn thành khối code Markdown kèm tên file và dòng đầu, dán vào chat hay Jira là đủ ngữ cảnh
map("x", "<leader>cc", function()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return vim.notify("buffer chưa có tên file", vim.log.levels.WARN)
  end
  local first, last = selected_lines()
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  -- rào dài hơn mọi chuỗi ``` có sẵn trong đoạn (vd. chép từ file Markdown) để khối không bị cắt giữa chừng
  local fence = "```"
  for _, line in ipairs(lines) do
    for ticks in line:gmatch "`+" do
      if #ticks >= #fence then
        fence = ticks .. "`"
      end
    end
  end
  local lang = ({ typescriptreact = "tsx", javascriptreact = "jsx" })[vim.bo.filetype] or vim.bo.filetype
  table.insert(lines, 1, ('%s%s filename="%s" line=%d'):format(fence, lang, vim.fn.fnamemodify(name, ":."), first))
  table.insert(lines, fence)
  copy(table.concat(lines, "\n"), ("đã chép %d dòng thành khối code"):format(last - first + 1))
end, { desc = "copy selection as markdown code block" })

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

map("n", "<leader>cs", "<cmd>Scaffold<cr>", { desc = "dotnet scaffold (model -> controller / view)" })

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
