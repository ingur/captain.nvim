local M = {}

local config = {
  path = vim.fn.stdpath("data") .. "/captain",
  autowrite = true,
  silent = false,
  git = true,
}

local projects = {}

local save_projects = function()
  local lines = vim.split(vim.inspect(projects), "\n")
  lines[1] = "return " .. lines[1]
  vim.fn.writefile(lines, config.path)
end

local load_projects = function()
  if vim.fn.filereadable(config.path) == 0 then return save_projects() end
  projects = dofile(config.path)
end

local setup_autowrite = function()
  local augroup = vim.api.nvim_create_augroup("HookAutowrite", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = augroup,
    pattern = "*",
    callback = function()
      if config.autowrite then pcall(save_projects) end
    end,
  })
end

local notify = function(...)
  if config.silent then return end
  local args = { ... }
  local lvl = #args > 1 and args[#args] or "INFO"
  local msg = args[1]
  table.remove(args, 1)
  table.remove(args, #args)
  vim.notify(string.format(msg, table.unpack(args)), vim.log.levels[lvl])
end

local get_cwd = function()
  local cwd = vim.fn.getcwd()
  if vim.loop.fs_stat(cwd .. "/.git") then
    local git_branch = vim.fn.system("git branch --show-current"):gsub("%s+", "")
    if git_branch ~= "" then
      cwd = string.format("%s (%s)", cwd, git_branch)
    end
  end
  return cwd
end

local hooked = function(cwd, fn)
  for i, f in pairs(projects[cwd]) do
    if f == fn then return i end
  end
end

M.info = function()
  local cwd = get_cwd()
  projects[cwd] = projects[cwd] or {}
  local msg = cwd .. ":"
  for i, fn in pairs(projects[cwd]) do
    msg = msg .. string.format("\n  [%s]: %s", i, fn)
  end
  vim.notify(msg, vim.log.levels["INFO"])
end

M.hook = function(idx)
  local cwd = get_cwd()
  projects[cwd] = projects[cwd] or {}
  if projects[cwd][idx] then
    local fn = projects[cwd][idx]
    if vim.fn.filereadable(fn) == 1 then
      if fn == vim.fn.expand("%") then return end
      vim.cmd("edit " .. fn)
    else
      projects[cwd][idx] = nil
      notify("%s -> file does not exist, unhooked from (%s)", fn, idx)
    end
  else
    local ffn = vim.fn.expand("%:p")
    if not string.find(ffn, vim.fn.getcwd(), 1, true) then return end
    local fn = vim.fn.expand("%")
    local jdx = hooked(cwd, fn)
    if jdx then
      notify("%s -> already hooked to (%s)", fn, jdx, "WARN")
    else
      projects[cwd][idx] = fn
      notify("%s -> hooked to (%s)", fn, idx, "INFO")
    end
  end
end

M.unhook = function(opts)
  opts = opts or {}
  local cwd = get_cwd()
  projects[cwd] = projects[cwd] or {}

  if opts.all then
    local len = #projects[cwd]
    projects[cwd] = nil
    notify("%s -> unhooked %s file(s)", cwd, len, "INFO")
  else
    local fn = vim.fn.expand("%")
    local idx = hooked(cwd, fn)
    if idx then
      projects[cwd][idx] = nil
      notify("%s -> unhooked from (%s)", fn, idx, "INFO")
    else
      notify("%s -> not hooked", fn, "WARN")
    end
  end
end

M.save = function()
  save_projects()
  notify("Saved all hooks", "INFO")
end

M.reset = function()
  projects = {}
  save_projects()
  notify("Deleted all hooks", "INFO")
end

M.setup = function(opts)
  ---@diagnostic disable-next-line: deprecated
  table.unpack = table.unpack or unpack
  config = vim.tbl_deep_extend("force", config, opts or {})
  load_projects()
  setup_autowrite()
end

return M
