## Hardware

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
