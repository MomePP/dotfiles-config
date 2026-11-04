## Hardware

Flashing a development build to a test board the work already uses is a
small decision: do it without asking, under the rules below, and report what
is on the board. Still ask before writing eFuses, secure boot or flash
encryption, or touching a device that ships or that the user is using.

When the work flashes, configures or tests a physical device:

- Pick a device by its serial number or MAC, never by its port name; ports
  renumber.
- Leave alone any device the user is using. Take the device's shared lock
  (Coordinated work) before touching it.
- Before any write, back up every region it touches to the main checkout's
  `.claude/backups/<device-serial>/`, with a checksum next to each image.
  Not a scratch worktree (removing the worktree deletes it), `.claude/tmp/`
  (deleted when work lands) or `/tmp` (wiped on reboot).
- Restore afterwards and check that the checksums match.
