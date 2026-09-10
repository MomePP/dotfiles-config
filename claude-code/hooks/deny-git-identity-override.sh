#!/usr/bin/env bash
# PreToolUse/Bash hook: refuse commands that rewrite the git author identity.
#
# permissions.deny covers `git config [--local|--global] user.name/user.email`,
# but not the two forms that bypass config entirely:
#   git -c user.email=x commit
#   GIT_AUTHOR_EMAIL=x git commit
# Those are what this catches. Reads (`git config --get user.email`) are allowed.
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

boundary='(^|[[:space:];&|(`]|\$\()'

# GIT_AUTHOR_* / GIT_COMMITTER_* environment overrides.
if printf '%s' "$cmd" | grep -qE "${boundary}GIT_(AUTHOR|COMMITTER)_(NAME|EMAIL)="; then
  deny "Blocked: GIT_AUTHOR_*/GIT_COMMITTER_* override the commit identity for this command. Commits must be authored momeppkt <peeranut32@gmail.com>. Drop the variable and let git read the configured identity."
fi

# git -c user.name=... / -c user.email=...
if printf '%s' "$cmd" | grep -qE "${boundary}git([[:space:]]+[^[:space:]]+)*[[:space:]]+-c[[:space:]]*user\.(name|email)="; then
  deny "Blocked: 'git -c user.name/user.email=' overrides the commit identity for this command. Commits must be authored momeppkt <peeranut32@gmail.com>."
fi

# git config ... user.name/user.email <value>, and --unset/--add/--replace-all.
if printf '%s' "$cmd" | grep -qE "${boundary}git([[:space:]]+[^[:space:]]+)*[[:space:]]+config([[:space:]]+[^[:space:]]+)*[[:space:]]+user\.(name|email)[[:space:]]+[^-[:space:]]"; then
  deny "Blocked: writing user.name/user.email changes the commit identity. Commits must be authored momeppkt <peeranut32@gmail.com>. Reads are fine: 'git config --get user.email'."
fi
if printf '%s' "$cmd" | grep -qE "${boundary}git([[:space:]]+[^[:space:]]+)*[[:space:]]+config[[:space:]]+([^[:space:]]+[[:space:]]+)*--(unset|unset-all|add|replace-all)([[:space:]]+[^[:space:]]+)*[[:space:]]+user\.(name|email)"; then
  deny "Blocked: unsetting or rewriting user.name/user.email changes the commit identity. Commits must be authored momeppkt <peeranut32@gmail.com>."
fi

exit 0
