## File paths in replies → always absolute

When a reply to the user names a file (a picture, a render sheet, a log,
a note, a source file), give its full absolute path:
`/Users/momeppkt/.paseo/worktrees/3kqa982k/gogo8-broadcast/.claude/tmp/broadcast-webui.png`,
not `.claude/tmp/broadcast-webui.png` or "in the !11 workspace".

- A picture the user should see goes in its own paragraph as a Markdown
  image: `![Option C sheet](/Users/momeppkt/…/chip-option-c.png)`. The
  better-paseo plugin draws only that form as the picture
  (`splitLocalImages()` in its `local-path.ts`). A bare path, plain or in
  backticks, shows as a clickable path, not the picture.
- Other files (logs, notes, source) stay as bare absolute paths; the
  plugin makes them clickable.
- Do not open a Paseo workspace only so the user can view a file in
  another worktree; the absolute path is enough. Open one only when the
  user asks, or to show a branch's diff.
- Repo-relative paths are fine inside code, commits, MR descriptions and
  knowledge files, where readers have other checkouts.
