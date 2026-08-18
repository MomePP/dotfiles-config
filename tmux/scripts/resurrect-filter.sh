#!/usr/bin/env bash
# Strip ephemeral panes and sessions out of a tmux-resurrect save file.
#
# Wired to `@resurrect-hook-post-save-layout`, which hands us the freshly
# written save file *before* resurrect compares it and links it to `last`.
# Filtering at save time rather than restore time means the 60-second dock
# tick heals an already-polluted `last` on its own.
#
# Three things end up in the save file that must never come back on restore:
#
#   * The tmux-agent-dock sidebar pane. Resurrect has no idea how to respawn
#     it, so it restores as a bare 30-column shell wedged beside the work
#     pane -- a dead sidebar you have to close by hand on every login.
#   * sidekick.nvim's agent sessions: `tmux new -A -s "<tool> <cwd-hash>"`,
#     owned by a Neovim float that is long gone by the next boot. They come
#     back as empty shells and clutter the dock's session list.
#   * Floating panes (tmux >= 3.7, `new-pane`, bound to `*`). tmux cannot
#     restore one: it saves them into `window_layout` but `select-layout`
#     rejects that same string, so the pane comes back as an ordinary tiled
#     split and takes the window's sizing down with it. See `tiled_layout`.
#
# Dropping a pane line leaves the window's saved layout describing one pane
# too many, so `select-layout` fails on restore and the window opens with
# default sizing. That is the intended outcome for the dock; a window that
# also had hand-sized work splits loses those sizes. Floating panes are the
# exception -- they are dropped from the layout as well, so the tiled splits
# around them keep their sizes.
#
# The save file is tab-delimited and session names contain spaces, so every
# field test has to go through `awk -F '\t'`.
set -euo pipefail

file="$1"
tmp="$file.filtered"
tab=$'\t'

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

# Which panes are floating, keyed the way resurrect keys its pane lines. The
# save file records no such flag and the numbers inside the layout string are
# pane *ids*, not the `pane_index` resurrect stores, so there is nothing in the
# file to recover this from -- ask the live server, which is still running.
#
# `==,1` here, the opposite polarity to the dock's own filter, because this asks
# for floating panes rather than against them. On tmux < 3.7 the variable does
# not exist and expands empty, empty `==` 1 is false, and the query returns
# nothing -- which is correct, since no floating pane can exist there.
FLOATING_PANES="$(tmux list-panes -a \
	-F "#{session_name}${tab}#{window_index}${tab}#{pane_index}" \
	-f '#{==:#{pane_floating_flag},1}' 2>/dev/null || true)"
export FLOATING_PANES

awk -F '\t' '
	BEGIN {
		OFS = "\t"
		rows = split(ENVIRON["EMBEDDED_SESSIONS"], row, "\n")
		for (i = 1; i <= rows; i++) {
			if (row[i] != "") { known[row[i]] = 1 }
		}
		rows = split(ENVIRON["FLOATING_PANES"], row, "\n")
		for (i = 1; i <= rows; i++) {
			if (row[i] != "") { floats[row[i]] = 1 }
		}
		for (i = 32; i < 127; i++) { ORD[sprintf("%c", i)] = i }
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
	function floating(session, window, pane) {
		return (session "\t" window "\t" pane) in floats
	}
	# tmux 3.7 writes a floating pane into the layout twice: once appended to
	# the end of the top-level container, and again in a `<...>` suffix listing
	# only the floaters. `select-layout` then refuses the whole string, so a
	# window that had a floater open at save time loses its split sizes even
	# though nothing about the tiled panes changed. Rebuild the layout without
	# them and it restores exactly as it did before the floater was opened.
	#
	# The suffix says how many cells to drop -- one per comma-separated value,
	# and the floaters are always the trailing cells of the top-level container.
	# That container closes with `]` for a vertical top-level split and `}` for
	# a horizontal one, so take whichever byte is there and put it back.
	#
	# The leading `%04x` is a checksum over everything after it, which tmux
	# verifies, so it has to be recomputed rather than carried over -- an edited
	# body under the old checksum is rejected exactly like the unedited one.
	function tiled_layout(layout,   mark, comma, body, floaters, closer, cells, dropped, cut, keep, i) {
		mark = index(layout, "<")
		if (mark == 0) { return layout }

		comma    = index(layout, ",")
		body     = substr(layout, comma + 1, mark - comma - 1)
		floaters = substr(layout, mark + 1, length(layout) - mark - 1)

		# `close` would be the obvious name for this; it is an awk builtin.
		closer = substr(body, length(body), 1)
		body   = substr(body, 1, length(body) - 1)

		cut  = split(body, cells, ",") - split(floaters, dropped, ",")
		keep = cells[1]
		for (i = 2; i <= cut; i++) { keep = keep "," cells[i] }
		keep = keep closer

		return layout_checksum(keep) "," keep
	}
	# tmux `layout_checksum`, layout-custom.c: rotate right through 16 bits,
	# then add the byte.
	function layout_checksum(body,   i, sum) {
		sum = 0
		for (i = 1; i <= length(body); i++) {
			sum = int(sum / 2) + (sum % 2) * 32768
			sum = (sum + ORD[substr(body, i, 1)]) % 65536
		}
		return sprintf("%04x", sum)
	}
	$1 == "pane"            && ($10 == "tmux-agent-dock" || ephemeral($2) ||
	                           floating($2, $3, $6))                      { next }
	$1 == "window"          && ephemeral($2)                              { next }
	$1 == "grouped_session" && (ephemeral($2) || ephemeral($3))           { next }
	# `state` records the session to switch back to. Left pointing at one we
	# just dropped, restore switch-clients to a session that will not exist.
	$1 == "state"           && (ephemeral($2) || ephemeral($3))           { next }
	# If a floater closed between the save and this hook its pane line is in the
	# file but not in the query, so the rewritten layout describes one pane too
	# few and `select-layout` fails -- the same default sizing the file already
	# falls back to elsewhere, not a new failure.
	$1 == "window"          { $7 = tiled_layout($7) }
	{ print }
' "$file" >"$tmp"

mv "$tmp" "$file"
