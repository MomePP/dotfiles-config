#!/usr/bin/env bash
# PreToolUse/Bash hook: the shell denylist for every command-running tool.
#
# permissions.deny matches command prefixes, so wrapped forms (bash -c 'sudo …')
# slip past it, and OMP has no permissions.deny at all. This script is the one
# place commands are refused, for Claude (PreToolUse) and OMP (the shell-guard
# extension) alike. Keep it in step with permissions.deny.
#
# stdin: PreToolUse JSON. stdout: deny verdict, or nothing when the command is fine.

set -uo pipefail

cmd=$(jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# A command word starts the string or follows a separator, a subshell, or a
# quote (bash -c 'sudo …'), so wrapped forms are caught too.
boundary='(^|[[:space:];&|(`"'\'']|\$\()'
end='([[:space:];&|)`"'\'']|$)'

matches() { printf '%s' "$cmd" | grep -qE "${boundary}$1"; }

matches "sudo${end}" && deny "Blocked: sudo is not allowed for agents. Ask the user to run it."
matches "(ssh|scp)${end}" && deny "Blocked: ssh/scp is not allowed for agents. Ask the user to run it."
matches "wget${end}" && deny "Blocked: wget is not allowed for agents."
matches "curl([[:space:]]+[^[:space:]]+)*[[:space:]]+[\"']?https?://" && deny "Blocked: curl to http(s) URLs is not allowed for agents."

exit 0
