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

awk -F '\t' '
	# Sidekick session ids are "<tool> <hex>", where the hash is truncated so
	# that the two halves plus the space always total 17 characters
	# (sidekick.nvim, lua/sidekick/cli/session/init.lua). Anchoring on the hex
	# tail *and* the width keeps real session names out of the net.
	function ephemeral(name) {
		return name ~ /^[A-Za-z0-9_.-]+ [0-9a-f]+$/ && length(name) == 17
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
