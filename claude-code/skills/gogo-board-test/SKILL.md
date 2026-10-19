---
name: gogo-board-test
description: How to use the GoGo 7F board and its co-MCU safely in tests. Covers the shared board lock, ports, coffee mode, flashing and recovery, HID markers, co-MCU backup and restore, the Tasmota USB caveat, keyboard tests and old firmware images. Use before any flash, serial, HID or co-MCU action on a GoGoBoard, or when writing a board test script.
user-invocable: true
---

# GoGo board test

There is one board and there are many agents. Follow every rule here.

## Lock

- **Take it:** `until mkdir /tmp/gogo-board.lock 2>/dev/null; do sleep 15; done`.
- **Check before flashing:** confirm the loop really took the lock. A timed-out loop once flashed anyway.
- **Release it:** `rmdir /tmp/gogo-board.lock` when the session ends, and on failure too.
- **Keep sessions short:** build outside the lock, and hold it for 30 minutes at most per session.
- **Stale lock:** if the lock has been held a long time with no board process in `ps`, it is probably stale. Confirm with the agents first, then clear it and log that you did.

## Firmware rules

- **Coffee mode:** every build you flash sets line 7 of `include/gogo-config.h` to `#define ENABLE_COFFEE_MODE`. Revert it before you commit.
- **Release images:** prebuilt release images beep, so keep runs on them short.
- **Wi-Fi:** the board must end on the owner's network. Send HID category 4 cmd 1 with the payload `ssid,password`. Ask the owner for the credentials; never hard-code them in committed files.

## Ports and flashing

- **Main board UART:** `/dev/cu.usbserial-0001`. Open it with `dtr=False, rts=False`, or the board resets.
- **Raw HID:** used for commands and the 63-byte report.
- **Normal flash:** `pio run -e debug -t upload --upload-port /dev/cu.usbserial-0001`.
- **If UART upload fails:**
  1. Send HID category 0 cmd 250 to enter the bootloader.
  2. Flash to the native port that appears (`/dev/cu.usbmodem*`).
  3. Check `esptool chip-id` says ESP32-S3 before writing.
- **Factory images:** flash at offset 0x0. They erase NVS, so restore Wi-Fi afterwards.
- **Wedged board:** a half-written flash, or an old release that panics on every boot, needs the owner to press RESET or replug. USB power cycling does not help, because the UART adapter keeps the board powered. Keep the lock and ask.

## Markers and scripts

- **Pass marker:** motor A on means the correct behaviour. It is report byte 23, `motor_status`, bit 0. `common.run_program` holds `a, on` for 3 s; `common.motor_on` checks it.
- **Other report bytes:**
  - Wi-Fi: byte 43;
  - firmware major: byte 19;
  - servo angles and relays: see `REG` in `gogo_hid.py`.
- **Same script on both builds:** run the same script on develop and on the fix. Save the script and its verbatim output under the notes `cleanup-<date>/board/`, with the branch as the file prefix.
- **Test design:** inputs must make wrong and right answers differ. Symmetric loop ranges once hid a slot bug.
- **Helpers:**
  - `gogo_hid.py`: `open_raw`, `packet`, `reports`, `compile_logo`, `REG`;
  - `common.py`: `download`, `stop`, `run_program`, `motor_on`;
  - Python: the venv with hid and pyserial.

  Their paths are in the session's memory and earlier briefs.

## Co-MCU (ESP32-C3 on the extension port)

- **Back up first:** before the first write, back up the whole flash. Run `esptool --port <c3 port> read-flash 0 ALL backup.bin` twice and compare the md5. Never overwrite the backup.
- **Restore before releasing:** before you release the lock, write the backup back to the co-MCU (`write-flash 0x0`).
- **Tasmota on Mac USB:** with the C3 connected to the Mac's USB, Tasmota uses USB CDC as its console and ignores the GoGo link. To test the link, switch that hub port off with `uhubctl` and restart Tasmota over HTTP.
- **Arduino library:** a C3 sketch that calls `Serial.begin` with USB CDC on boot turned off takes UART0, which is the GoGo link.
- **Detection:** the main board shows the detected co-MCU kind only in the UART log (`co-MCU auto-detect -> X`) and on the Settings display row.

## Keyboard tests

- **Modifiers only:** observe only modifier keys, through Quartz `CGEventSourceFlagsState(kCGEventSourceStateHIDSystemState)`. Never let a character key type into a window, and leave nothing held at the end.
- **Wake the display:** run `caffeinate -u -t 1` before each Run, because macOS swallows the keystroke that wakes the display.
- **Space key commands apart:** put about 300 ms between key commands, because back-to-back commands overwrite one pending slot.
- **Raw HID is not needed:** keyboard output does not depend on anyone reading the raw HID interface.

## Old firmware

- **Old tags:** release tags such as 3.2.6 may no longer build. Use the factory images in GitHub `lilcmu/gogo7-firmware-installer/firmware/`.
- **Bootloop risk on 3.2.6:** a `stop` inside `forever` in the start procedure panics 3.2.6 and leaves it bootlooping. Avoid that program shape on old images.

## Tooling prerequisites

- **Shell allowlist.** The lean-ctx shell allowlist must include:
  - `pio`, `esptool`, `esptool.py`;
  - `python`, `python3`;
  - `caffeinate`, `timeout`, `uhubctl`;
  - `git`, `glab`, `gh`;
  - `rsync`, `node`, `mkdir`, `rmdir`, `base64`.
- **Paths.** Run `lean-ctx allow-path` for the session worktree root.
- **Inline scripts.** Set `shell_allow_inline_scripts = true`.
- **If a command is blocked:** list the missing entries for the owner. Do not route around the gate.
