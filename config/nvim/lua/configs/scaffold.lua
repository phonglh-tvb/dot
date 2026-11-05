-- :Scaffold sinh controller / view / Razor Page / Blazor / Minimal API từ một model C#, như
-- "Add > New Scaffolded Item" của Visual Studio. Engine là dotnet-aspnet-codegenerator (cài bằng mise, xem
-- config/mise/config.toml). Project cần package Microsoft.VisualStudio.Web.CodeGeneration.Design và Entity
-- Framework Core (Tools + provider); thiếu gói nào tool tự báo trong output.
--
--   :Scaffold            chọn kiểu sinh, model lấy từ class đang đứng (hoặc chọn trong Models/)
--   :Scaffold controller bỏ qua bước chọn kiểu (controller view razorpage blazor minimalapi)
--   :Scaffold!           ghi đè file đã có (controller, view, razorpage)
local M = {}

local TOOL = "dotnet-aspnet-codegenerator"

local ignored_dirs = { bin = true, obj = true, node_modules = true, wwwroot = true, [".git"] = true }

local function notify(msg, level)
  vim.notify("Scaffold: " .. msg, level or vim.log.levels.INFO)
end

-- Hỏi người dùng tuần tự: vim.ui.select / vim.ui.input đều trả lời qua callback (bản mặc định gọi ngay lập tức),
-- nên cả luồng chạy trong coroutine và callback chỉ resume sau vim.schedule.
local function resume(co, ...)
  local ok, err = coroutine.resume(co, ...)
  if not ok then
    notify(debug.traceback(co, tostring(err)), vim.log.levels.ERROR)
  end
end

local function choose(items, opts)
  local co = coroutine.running()
  vim.ui.select(items, opts, function(choice)
    vim.schedule(function()
      resume(co, choice)
    end)
  end)
  return coroutine.yield()
end

local function input(opts)
  local co = coroutine.running()
  vim.ui.input(opts, function(text)
    vim.schedule(function()
      resume(co, text)
    end)
  end)
  return coroutine.yield()
end

local function find_root(source)
  return vim.fs.root(source, function(name)
    return name:match "%.csproj$" ~= nil
  end)
end

---@param root string thư mục chứa .csproj
local function cs_files(root)
  local files = {}
  local skip = function(dir)
    return not ignored_dirs[dir]
  end
  for path, kind in vim.fs.dir(root, { depth = 8, skip = skip }) do
    if kind == "file" and path:match "%.cs$" then
      files[#files + 1] = vim.fs.joinpath(root, path)
    end
  end
  return files
end

---@class ScaffoldType
---@field name string
---@field full string tên đầy đủ kèm namespace
---@field lnum integer
---@field text string dòng khai báo

-- Đọc class / record từ text, không cần treesitter hay LSP; hiểu cả namespace file-scoped lẫn block.
---@param lines string[]
---@return ScaffoldType[]
local function parse_types(lines)
  local ns, found = nil, {}
  for lnum, line in ipairs(lines) do
    ns = line:match "^%s*namespace%s+([%w_.]+)" or ns
    if not line:find "%f[%w]static%f[%W]" then
      local name = line:match "^%s*[%w%s]-%f[%w]class%s+([%w_]+)" or line:match "^%s*[%w%s]-%f[%w]record%s+([%w_]+)"
      if name then
        found[#found + 1] = { name = name, full = ns and (ns .. "." .. name) or name, lnum = lnum, text = line }
      end
    end
  end
  return found
end

---@return ScaffoldType?
local function pick_model(buf, root)
  if vim.bo[buf].filetype == "cs" then
    local types = parse_types(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
    if #types > 0 then
      -- class gần nhất phía trên con trỏ, không có thì class đầu tiên
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local pick = types[1]
      for _, t in ipairs(types) do
        if t.lnum <= row then
          pick = t
        end
      end
      return pick
    end
  end

  local items = {}
  for _, file in ipairs(cs_files(root)) do
    if file:find("/Models/", 1, true) or file:find("/Entities/", 1, true) then
      vim.list_extend(items, parse_types(vim.fn.readfile(file)))
    end
  end
  if #items == 0 then
    notify("không thấy model nào; mở file model rồi chạy lại", vim.log.levels.WARN)
    return
  end
  return choose(items, {
    prompt = "Model",
    format_item = function(t)
      return t.full
    end,
  })
end

---@return string? tên đầy đủ của DbContext
local function pick_dbcontext(root)
  local found = {}
  for _, file in ipairs(cs_files(root)) do
    for _, t in ipairs(parse_types(vim.fn.readfile(file))) do
      if t.text:match "class%s+[%w_]+[^:]*:%s*[%w_.]*DbContext%f[^%w_]" then
        found[#found + 1] = t.full
      end
    end
  end
  if #found == 1 then
    return found[1]
  elseif #found > 1 then
    return choose(found, { prompt = "DbContext" })
  end

  local project = vim.fn.fnamemodify(vim.fn.glob(root .. "/*.csproj", false, true)[1] or "", ":t:r")
  return input {
    prompt = "DbContext (chưa có thì tool tạo mới): ",
    default = ("%s.Data.%sContext"):format(project, project),
  }
end

local function plural(word)
  if word:match "[^aeiou]y$" then
    return word:sub(1, -2) .. "ies"
  elseif word:match "[sxz]$" or word:match "[cs]h$" then
    return word .. "es"
  end
  return word .. "s"
end

-- Mỗi kiểu trả về tham số của tool (không gồm -m / -dc / -f), hoặc nil nếu người dùng huỷ.
-- `force`: tool có hỗ trợ -f; blazor và minimalapi thì không.
local generators = {
  {
    name = "controller",
    label = "MVC: controller + view (Index, Create, Edit, Delete, Details)",
    force = true,
    args = function(model)
      local name = input { prompt = "Tên controller: ", default = plural(model.name) .. "Controller" }
      if not name or name == "" then
        return
      end
      return { "controller", "-name", name, "-outDir", "Controllers", "-udl", "-scripts", "-async" }
    end,
  },
  {
    name = "view",
    label = "MVC: một view riêng (Create, Edit, Delete, Details, List, Empty)",
    force = true,
    args = function(model)
      local template = choose({ "List", "Create", "Edit", "Details", "Delete", "Empty" }, { prompt = "Template view" })
      if not template then
        return
      end
      local name = input { prompt = "Tên view: ", default = template == "List" and "Index" or template }
      local dir = name and input { prompt = "Thư mục: ", default = "Views/" .. plural(model.name) }
      if not dir or name == "" then
        return
      end
      return { "view", name, template, "-outDir", dir, "-udl", "-scripts" }
    end,
  },
  {
    name = "razorpage",
    label = "Razor Pages: Create, Edit, Delete, Details, Index",
    force = true,
    args = function(model)
      local dir = input { prompt = "Thư mục: ", default = "Pages/" .. plural(model.name) }
      if dir then
        return { "razorpage", "-outDir", dir, "-udl", "-scripts" }
      end
    end,
  },
  {
    name = "blazor",
    label = "Blazor: component CRUD (cần Microsoft.AspNetCore.Components.QuickGrid)",
    args = function(model)
      local template = choose(
        { "CRUD", "Create", "Edit", "Delete", "Details", "List", "Empty" },
        { prompt = "Template Blazor" }
      )
      local dir = template and input { prompt = "Thư mục: ", default = "Components/Pages/" .. model.name .. "Pages" }
      if dir then
        return { "blazor", template, "-outDir", dir }
      end
    end,
  },
  {
    name = "minimalapi",
    label = "Minimal API: file endpoint CRUD",
    args = function(model)
      local class = input { prompt = "Tên class endpoint: ", default = model.name .. "Endpoints" }
      if class and class ~= "" then
        return { "minimalapi", "-e", class, "-outDir", "Endpoints" }
      end
    end,
  },
}

local function show_output(text)
  vim.cmd "botright 15new"
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(vim.trim(text), "\r?\n"))
  -- cảnh báo NuGet đứng trước lỗi build thật nên nhảy tới chữ "error"; lỗi của tool (thiếu package...) nằm ở dòng cuối
  if vim.fn.search "\\<error\\>" == 0 then
    vim.cmd "normal! G"
  end
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buf = buf, desc = "Close" })
end

-- Tool in "Added View : /Views/Products/Create.cshtml" (đường dẫn tương đối project, riêng blazor là tuyệt đối).
local function created_files(output, root)
  local files = {}
  for line in output:gmatch "[^\r\n]+" do
    local path = line:match "^Added [^:]-:%s*(.+)$"
    if path then
      path = path:gsub("^'(.-)'%.?$", "%1")
      files[#files + 1] = vim.startswith(path, root) and path or vim.fs.joinpath(root, path)
    end
  end
  return files
end

local function exec(root, args)
  notify "đang build và sinh code..."
  vim.system(vim.list_extend({ TOOL }, args), { cwd = root, text = true }, function(res)
    vim.schedule(function()
      local output = (res.stdout or "") .. (res.stderr or "")
      local files = created_files(output, root)
      if res.code ~= 0 or #files == 0 then
        local hint = output:find("use -f", 1, true) and " (:Scaffold! để ghi đè)" or ""
        local last = vim.trim(output):match "([^\r\n]*)$"
        notify("không sinh được file nào" .. hint .. ": " .. last:sub(-200), vim.log.levels.ERROR)
        return show_output(output)
      end

      vim.fn.setqflist({}, " ", {
        title = "Scaffold",
        items = vim.tbl_map(function(file)
          return { filename = file, lnum = 1 }
        end, files),
      })
      pcall(function()
        require("nvim-tree.api").tree.reload()
      end)
      vim.cmd.edit(vim.fn.fnameescape(files[1]))
      notify(("đã sinh %d file (danh sách trong quickfix: <leader>ql)"):format(#files))
    end)
  end)
end

---@param name string? tên kiểu sinh; nil thì hỏi
---@param force boolean? ghi đè file đã có
function M.run(name, force)
  local buf = vim.api.nvim_get_current_buf()
  local root = find_root(buf) or find_root(vim.uv.cwd())
  if not root then
    return notify("không thấy .csproj quanh file này", vim.log.levels.ERROR)
  elseif vim.fn.executable(TOOL) == 0 then
    return notify(TOOL .. " chưa có; chạy 'mise install'", vim.log.levels.ERROR)
  end

  local gen
  if name then
    gen = vim.iter(generators):find(function(g)
      return g.name == name
    end)
    if not gen then
      return notify("không có kiểu '" .. name .. "'", vim.log.levels.ERROR)
    end
  else
    gen = choose(generators, {
      prompt = "Scaffold",
      format_item = function(g)
        return g.label
      end,
    })
  end
  if not gen then
    return
  end

  local model = pick_model(buf, root)
  local context = model and pick_dbcontext(root)
  if not context or context == "" then
    return
  end

  local args = gen.args(model)
  if not args then
    return
  end
  vim.list_extend(args, { "-m", model.full, "-dc", context })
  if force and gen.force then
    args[#args + 1] = "-f"
  end

  vim.cmd "silent! wall" -- tool build project, nên model vừa sửa phải nằm trên đĩa
  exec(root, args)
end

vim.api.nvim_create_user_command("Scaffold", function(opts)
  resume(coroutine.create(M.run), opts.args ~= "" and opts.args or nil, opts.bang)
end, {
  nargs = "?",
  bang = true,
  complete = function()
    return vim.tbl_map(function(g)
      return g.name
    end, generators)
  end,
  desc = "dotnet scaffold: model -> controller / view / Razor Page / Blazor / Minimal API",
})

return M
