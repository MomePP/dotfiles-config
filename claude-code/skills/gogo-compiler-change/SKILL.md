---
name: gogo-compiler-change
description: Proves a gogo-logo-compiler change is correct and backward compatible for GoGo 7 boards on every firmware version that shares the dev compiler. Covers host probes, cold corpus sweeps, and board runs on 3.2.6 and 4.x factory images. Use for any change or review of tinkerlogo.py.
user-invocable: true
---

# GoGo compiler change

**Merging into compiler `develop` redeploys the production compiler that every GoGo 7 uses** (`/logo/dev/compile`). Open MRs only; the owner merges.

## Facts to rely on

- **Firmware version sent:** for a GoGo 7 the webapp sends only the firmware major, `"3"` or `"4"`. It is built in `deviceProcess.js` and posted in `deviceControl.js`. The compiler gates features on that major (`FEATURE_MIN_FIRMWARE`); for example, for loops and locals need 4.
- **Never call production:** do not call the production compile API from tests.
- **Shared tables on warm servers:** class-level tables shared across `compile()` calls once made warm servers drift. Always compare against a "cold" develop, with tables cleared before each compile.
- **PLY tables:** PLY writes `parsetab.py` next to the module and loads the first one on `sys.path` without checking it. Run every compiler from its own copy (`rsync -a --exclude .git`). Deploy `tinkerlogo.py` and `parsetab.py` together.

## Proof for every change

1. **Host probes.** Assert literal bytes or literal messages, never "it compiled". Save the script under the notes `host-tests/compiler/`.
2. **Corpus sweep.** Compile every Logo program found in the repos and board scripts, with firmware set to `4`, `3` and none, on cold develop and on the branch. The required result is 0 changed bytes among successful compiles, and every other difference explained.
3. **Board check.** Run the changed programs on the board, with the motor-A marker (see `gogo-board-test`).
4. **Backward compatibility.** Flash each GoGo 7 firmware image in use. The factory images in GitHub `lilcmu/gogo7-firmware-installer/firmware/` include 3.2.6, 4.0.0-preview and 4.0.0-dev-*; add a develop build. Run on each:
   - each MR's targeted cases, made legal for that firmware major;
   - a regression set of ordinary classroom programs.

   Compare develop against a merged tree of all open compiler MRs. A program that passes with develop and fails with the merged tree is a compatibility break.
5. **Opcodes on old firmware.** Check that every opcode the change emits exists in the oldest firmware it can reach. For example, `OP_COMPUTE` exists from 3.1.0.

## Review notes

- **Turning crashes into errors.** When a change turns crashes into compile errors, check that the first error message wins and that the live Lambda wrapper still reads `error_msg is None` as success.
- **CHANGELOG conflicts.** Every MR appends to `CHANGELOG.md` under Unreleased, so they conflict. Keep all entries.
- **Firmware bugs.** Programs that fail identically on every compiler are firmware bugs, not compiler bugs. Report them separately.
