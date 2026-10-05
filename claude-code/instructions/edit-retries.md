## Edit-tool retries

When the `Edit` tool returns "String to replace not found in file",
do not stop and ask the user to continue. The mismatch is almost
always single-character drift between in-context memory and the
file on disk (a hyphen, a renamed identifier, a reflowed comment).

Recovery, no prompting required:

1. `Read` the target region from disk to get the exact bytes.
2. Rebuild `old_string` from those bytes verbatim.
3. Retry the `Edit`.

Only escalate to the user if a second attempt — built from a fresh
`Read` — also fails. The same rule applies to `Write` failures
caused by stale file-state tracking: re-`Read`, then retry.
