local cli = require("neogit.lib.git.cli")
local log = require("neogit.lib.git.log")
local util = require("neogit.lib.util")

local M = {}

---Pushes to the remote and handles password questions
---@param remote string
---@param branch string
---@param args string[]
---@return ProcessResult
function M.push_interactive(remote, branch, args)
  local b = string.format("refs/heads/%s:refs/heads/%s", branch, branch)
  return cli.push.args(remote or "", b or "").arg_list(args).call_interactive()
end

local function update_unmerged(state)
  state.upstream.unmerged.items = {}
  state.pushRemote.unmerged.items = {}

  if state.head.branch == "(detached)" then
    return
  end

  if state.upstream.ref then
    state.upstream.unmerged.items =
      util.filter_map(log.list({ "@{upstream}.." }, nil, {}, true), log.present_commit)
  end

  local pushRemote = require("neogit.lib.git").branch.pushRemote_ref()
  if pushRemote then
    state.pushRemote.unmerged.items =
      util.filter_map(log.list({ pushRemote .. ".." }, nil, {}, true), log.present_commit)
  end
end

function M.register(meta)
  meta.update_unmerged = update_unmerged
end

return M
