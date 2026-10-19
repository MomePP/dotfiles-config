---
name: gogo-flow-audit
description: Finds real GoGoBoard bugs by tracing one user action end to end across FreeRTOS tasks, the webapp HID contract, the Logo compiler and the co-MCU. Each finding is checked by a refuter and turned into board test cases. Use when asked to find bugs, audit the firmware, review a subsystem, or plan the next batch of GoGoBoard fixes.
user-invocable: true
---

# GoGo flow audit

A per-file audit mostly finds dead code. The bugs that matter appear when you follow one user action through every task and every peer. Examples from earlier runs:
- Wi-Fi credentials were saved but never applied while auto-reconnect was mid-attempt.
- `dobackgroundoff` never ended the program.
- A compiler slot model disagreed with the VM's.

## 1. Pick flows

Use one read-only auditor per flow:
- network (Wi-Fi, MQTT, portal, remote access);
- program lifecycle (start, stop, end, halt);
- webapp HID contract;
- co-MCU link (firmware against the vernier-firmware and GoGoBoard-Arduino repos);
- persistence and boot (NVS layouts across versions);
- compiler/VM opcode contract;
- menu and display state machine;
- datalog;
- outputs;
- inputs;
- messaging.

Before choosing, read the earlier triage files so finished flows are not redone.

## 2. Auditor brief (must include)

- **Read-only, everywhere.** Use absolute paths. No builds, no board, no network, and no `git checkout`, `switch` or `reset` in any repo; read other revisions with `git show`. Scratch files go under `/tmp/<slice>/`.
- **Knowledge first.** Read the subsystem's `.claude/knowledges/*.md` files first.
- **Exclusions.** What not to re-report: open MRs, earlier triage files, and decisions the owner already took.
- **Report shape.** Write `.audit/flow-<slice>.md` with:
  - a flow map;
  - up to 10 findings ranked by classroom impact, with confidence (CONFIRMED / SUSPECTED / QUESTION), trigger, file:line chain, fix shape and size, and a board repro;
  - simplifications;
  - owner questions.
- **Return value.** Return the top 3 findings only.

## 3. Refute before building

Run one `refuter` over all the reports. It:
- re-reads each chain and gives a verdict: CONFIRMED, REFUTED (naming the broken link) or UNPROVEN (naming the cheapest proof);
- dedupes across reports and against open MRs;
- names the repo each fix belongs in;
- ranks the findings into MR-sized batches.

For compiler findings it shows the emitted bytes, and checks whether GoCode's block generators can produce that Logo.

Expect several refutations every round. Never build on a finding that is not CONFIRMED.

The refuter also writes a board script, `flow<N>_board.py`, with one case per board-observable finding:
- motor-A marker = correct behaviour;
- a `--compile` flag that compiles every case without the board;
- a control case;
- the script compiles every case, but does not run it.

## 4. Confirm on the board

The coordinator runs the script on develop (see `gogo-board-test`). Predicted failures confirm the findings. A case that passes on develop is dropped or re-examined: in one run, a 300-character literal case did not reproduce.

## 5. Output

- **Verdicts.** `.audit/flow<N>-triage.md` holds the verdict table, ranked batches and merged owner questions.
- **Notes.** Copy the reports into the notes `flow/` folder (see `gogo-notes`).
- **Questions.** Owner questions go into `decisions-needed.md`, never into the MRs.
