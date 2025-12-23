local M = {}

---@class GitDiffTool.Config
local default_opts = {
    -- Dir for storing the diffed files. Use tmp directory, if you don't care about restoring the diff from session
    diff_files_dir = vim.fs.joinpath( vim.fn.stdpath("state") , "git-difftool")
}

---@type GitDiffTool.Config
M.options = { }

M.setup = function(opts)
  M.options = vim.tbl_deep_extend('force', {}, default_opts, opts or {})
end

---@param revision string git revision that can be commit hash, branch name, tag or ref
---@return string
local function convert_sha_into_temp_dir(revision)
  local temp_dir_path = vim.fn.tempname()
  vim.fn.mkdir(temp_dir_path, 'p')

  local res = vim
    .system({
      vim.o.shell,
      vim.o.shellcmdflag,
      string.format('git archive %s | tar -x -C %s', revision, temp_dir_path),
    })
    :wait()

  if res.code ~= 0 then
    vim.notify(res.stderr, vim.log.levels.ERROR)
  end
  return temp_dir_path
end

---@param left_revision string The left revision for comparison
---@param right_revision string The left revision for comparison
M.diff = function(left_revision, right_revision)
  local left_dir = convert_sha_into_temp_dir(left_revision)
  local right_dir = convert_sha_into_temp_dir(right_revision)

  require('difftool').open(left_dir, right_dir)
end

return M
