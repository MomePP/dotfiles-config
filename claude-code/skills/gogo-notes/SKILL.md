---
name: gogo-notes
description: Keeps the GoGoBoard owner-facing record on the experiment/perf-playground branch. Covers the decision trail, the MR decision guide, the separate decisions-needed doc, open work, run records and board evidence, plus removing stale notes. Use when recording a run, updating notes after MRs open or merge, or preparing questions for the owner.
user-invocable: true
---

# GoGo notes

The owner reads the notes to review and merge MRs and to answer questions. They live in `.claude/notes/` on the `experiment/perf-playground` branch. Never put them in the owner's checkout.

## Files

| File | Holds |
|---|---|
| `mr-decision-guide.md` | open MRs and PRs only, grouped as ready to merge, needs a decision, needs a test, or draft; plus the merge order |
| `decisions-needed.md` | every question only the owner can answer, in one place. Each has an ID, plain wording, options with the recommendation marked, what it blocks, and full MR or PR links. It also lists the calls made under the owner's grant, for him to confirm or overturn |
| `open-work.md` | pending checks, by what they need (hardware, a person), and the larger tracks. No questions |
| `merged-behaviour-changes.md` | what merged batches changed for users, and the watch list |
| `<run>-<date>.md` | the dated run record: answers, MRs opened, merge notes, disclosures |
| `cleanup-<date>/` | `board/` scripts and verbatim outputs, `host-tests/`, `flow/` audit and triage copies, and `decisions.tsv` |

## Rules

- **MR state.** Get it from the API (`glab api ".../merge_requests?state=opened&per_page=100"`, `gh pr list`), never from memory. Include every open MR in each repo, even ones outside the current work, listed by title.
- **Decision trail.** As each step lands, append a row with the show-me-your-work `log.sh` to `.audit/cleanup-run.tsv`, then copy it to `cleanup-<date>/decisions.tsv`. Each row records the phase, decision, why, evidence and result.
- **Owner questions.** Workers' `DECISION:` lines go into `decisions-needed.md`, with links. Drop questions the owner answered or that an open MR now decides, and say which MR.
- **Stale notes.** Remove a note once it is superseded, done, or shipped. Keep notes that a knowledge file on develop links to. Before removing a section, move any fact that exists only there.
- **Evidence.** Keep the scripts and the verbatim outputs. Drop regenerable bulk: copied sources, multi-MB sweep JSON, raw logs, `__pycache__`.
- **Commits.** Commit as `docs(notes): …` and push. Never commit coffee mode (`include/gogo-config.h`).

## Writing

- Plain English and short declarative sentences.
- No em dashes, and no colon as a mid-sentence connector.
- Label every claim as measured, host, code, or guess.
- Disclose anything an agent did outside its brief.
