---
name: gogo-dev-auto
description: Orchestrates an autonomous GoGoBoard campaign across gogo-firmware, gogo-logo-compiler, gogo-code and the co-MCU repos. Audits by flow, refutes findings, reproduces each on the GoGo 7F, then opens one reviewed MR per fix. Ends with an owner decisions doc. Use for "/gogo-dev-auto" (Claude Code), "/skill:gogo-dev-auto" (OMP), "find bugs and open MRs", "keep working while I'm AFK", "night run", or any multi-MR GoGoBoard run the owner reviews later.
user-invocable: true
---

# GoGo dev auto

The entry point. It runs the loop and delegates each phase to a sibling skill.

**Arguments:** $ARGUMENTS gives the scope, e.g. "co-MCU", "compiler" or "night run". With no arguments, find bugs, optimise, simplify and open MRs.

## Sibling skills (read the one a phase names)

| Skill | Use it for |
|---|---|
| `gogo-flow-audit` | finding bugs: flow audits, refuter triage, board scripts |
| `gogo-board-test` | anything that touches the GoGo 7F or the co-MCU: lock, ports, flashing, recovery, markers |
| `gogo-mr-pipeline` | turning a confirmed finding into a reviewed, opened MR |
| `gogo-compiler-change` | compiler MRs: host probes, sweeps, backward compatibility per firmware |
| `gogo-notes` | the notes branch, decision trail, decisions doc, cleanup |

## Owner rules (non-negotiable)

- **Owner checkouts.** Never touch the owner's checkouts in `~/Developer/`, which hold uncommitted work. Work in worktrees or fresh clones under `~/.paseo/worktrees/<session>/`, with absolute paths. Every subagent brief repeats this rule.
- **Allowed without asking:**
  - build, flash, serial and HID;
  - pushing feature and bugfix branches;
  - opening MRs, and draft PRs on the LILCMU GitHub repos.
- **Ask first** before merging, force-pushing a shared branch, or posting anywhere else.
- **Production stays untouched.** Make no calls to production services: the compile API and the MQTT broker.
- **Owner decisions are final.** Never re-ask a question the owner already answered. Copy those answers into every brief.
- **Blocked commands.** If a command is blocked, list the missing allowlist entries for the owner. Do not route around the gate.

## The loop

1. **Frame.** Open a todo list. State the predicate, e.g. "each MR proven on the board or by a host test, independently reviewed, opened". List the decisions already taken.
2. **Find.** Run `gogo-flow-audit`. Its output is a ranked list of confirmed findings with a board script.
3. **Reproduce.** Run the board script on develop (`gogo-board-test`). A finding either fails on develop or is labelled code-only.
4. **Fix.** Use `gogo-mr-pipeline`: one concern per branch, before/after on the board, an independent review, then open the MR. Compiler fixes also go through `gogo-compiler-change`.
5. **Record.** Use `gogo-notes`: a decision-trail row as each step lands, MR guide updates, and the owner questions in `decisions-needed.md`.
6. **Repeat.** Start a new round on a new flow while MRs are in review. Stop when the scope is covered or the remaining items need owner answers.
7. **Hand back.** Reply with:
   - what changed for children and teachers;
   - the evidence label on each item;
   - every MR link;
   - disclosures, meaning anything an agent did outside its brief;
   - a pointer to `decisions-needed.md`.

## Running many agents

- One worker per branch. The coordinator owns pushing, opening MRs and the notes.
- Read-only auditors and reviewers never edit, build or flash.
- After a FIX verdict, send the consolidated brief to a fresh worker.
- When a worker reports a slip, check every checkout (`git worktree list` plus `git status`) and record it as a disclosure.
- Answer worker questions quickly, and route board conflicts through the lock.
