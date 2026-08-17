#!/usr/bin/env bash
# Strip ephemeral panes and sessions out of a tmux-resurrect save file.
#
# Wired to `@resurrect-hook-post-save-layout`, which hands us the freshly
# written save file *before* resurrect compares it and links it to `last`.
# Filtering at save time rather than restore time means the 60-second dock
# tick heals an already-polluted `last` on its own.
#
# Two things end up in the save file that must never come back on restore:
#
#   * The tmux-agent-dock sidebar pane. Resurrect has no idea how to respawn
#     it, so it restores as a bare 30-column shell wedged beside the work
#     pane -- a dead sidebar you have to close by hand on every login.
#   * sidekick.nvim's agent sessions: `tmux new -A -s "<tool> <cwd-hash>"`,
#     owned by a Neovim float that is long gone by the next boot. They come
#     back as empty shells and clutter the dock's session list.
#
# Dropping a pane line leaves the window's saved layout describing one pane
# too many, so `select-layout` fails on restore and the window opens with
# default sizing. That is the intended outcome for the dock; a window that
# also had hand-sized work splits loses those sizes.
#
# The save file is tab-delimited and session names contain spaces, so every
# field test has to go through `awk -F '\t'`.
set -euo pipefail

file="$1"
tmp="$file.filtered"

# The dock already knows which sessions are embedded, and it knows by tracing
# each client's pid through the process tree rather than by guessing at names.
# It remembers the mapping in a tmux option (`session\tpane` per line) precisely
# so a session survives its float closing -- which is the state resurrect saves
# in. Ask it instead of re-deriving the answer.
#
# Handed over in the environment, not through `awk -v`: the value is one record
# per line, and -v runs the assignment through escape processing, where an
# embedded newline is an error ("newline in string") rather than a newline.
#
# `|| true` because `set -e` would otherwise abort on a failed query and leave
# the save unfiltered -- and resurrect discards a hook's exit status, so that
# abort would be silent, which is the failure mode this lookup exists to end.
# An empty value simply falls through to the name-shape rule below.
EMBEDDED_SESSIONS="$(tmux show-option -gqv @tmux_agent_dock_embedded 2>/dev/null | cut -f1 || true)"
export EMBEDDED_SESSIONS

awk -F '\t' '
	BEGIN {
		rows = split(ENVIRON["EMBEDDED_SESSIONS"], row, "\n")
		for (i = 1; i <= rows; i++) {
			if (row[i] != "") { known[row[i]] = 1 }
		}
	}
	# Name shape is the fallback for when the dock has not run yet (fresh
	# server, no agent opened): sidekick session ids are "<tool> <hex>", the
	# hash truncated so the two halves plus the space total 17 characters
	# (sidekick.nvim, lua/sidekick/cli/session/init.lua). That arithmetic is
	# sidekick internals -- it holds today only because the numbered-clone
	# tool names are 8 characters -- so it is the guess, not the answer.
	function ephemeral(name) {
		return (name in known) ||
			(name ~ /^[A-Za-z0-9_.-]+ [0-9a-f]+$/ && length(name) == 17)
	}
	$1 == "pane"            && ($10 == "tmux-agent-dock" || ephemeral($2)) { next }
	$1 == "window"          && ephemeral($2)                              { next }
	$1 == "grouped_session" && (ephemeral($2) || ephemeral($3))           { next }
	# `state` records the session to switch back to. Left pointing at one we
	# just dropped, restore switch-clients to a session that will not exist.
	$1 == "state"           && (ephemeral($2) || ephemeral($3))           { next }
	{ print }
' "$file" >"$tmp"

mv "$tmp" "$file"
