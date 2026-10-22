# OMP workflow benchmark, 2026-10-22

Baseline is the live config (`~/.config/omp`, lean-ctx replace mode). Optimized is this worktree's
`omp/extensions/lean-ctx.ts`, `omp/config.yml` and the `read` vs `ctx_read` bullet from `omp/AGENTS.md`.

Rerun with `python3 .bench/run.py [reps] [model] [thinking]` from the worktree root. Each run is
`omp -p --mode json --no-session` with a fresh fixture copy, opus-5-5 at thinking `low`, 2 reps.
The optimized arm swaps extensions through a config overlay (`disabledExtensions:
[extension-module:lean-ctx]` plus `extensions: [.bench/ext/lean-ctx-opt.ts]`), because `-e <path>`
fails with "Cannot find package '@earendil-works/pi-coding-agent'".

## Results (mean of 2 reps)

| task | base turns | opt turns | base errors | opt errors | base ctx tokens | opt ctx tokens | base wall s | opt wall s |
|---|---|---|---|---|---|---|---|---|
| skill-url | 4.0 | 2.0 | 2.0 | 0 | 136,869 | 53,726 | 9.8 | 4.0 |
| edit | 5.5 | 3.5 | 1.5 | 0 | 190,455 | 78,653 | 19.1 | 8.4 |
| code-question | 3.0 | 2.0 | 0 | 0 | 103,950 | 46,105 | 7.5 | 3.9 |
| dotfiles-read | 2.0 | 2.0 | 0 | 0 | 69,325 | 46,254 | 3.9 | 3.7 |
| rule-url | 3.0 | 2.0 | 2.0 | 0 | 101,764 | 45,335 | 9.9 | 3.5 |
| shell | 2.0 | 2.0 | 0 | 0 | 67,571 | 44,456 | 4.7 | 6.4 |
| explain-big | 3.0 | 2.0 | 0 | 0 | 104,496 | 46,179 | 12.2 | 7.8 |

- All 14 runs per arm passed their checks.
- Context tokens (input + cache read + cache write, summed over turns) fell 53%: 774k to 361k.
- First request: 33.7k tokens and 28 top-level tools (baseline) vs 22.2k and 13 (optimized).
- Tool errors: 11 vs 0. Baseline errors are `ctx_read` on `skill://`/`rule://` (ENOENT), the eval
  `read()` helper ("Unknown tool from js runtime: read"), and turns cut short by unresolved `write`.
- Dollar cost is not comparable across arms: the baseline prefix was already cached from earlier
  runs, so the optimized arm paid the first cache writes.

## Three-arm rerun with native-only (2026-10-23)

`BENCH_ARMS=baseline,optimized,native python3 .bench/run.py 2`. The native arm disables the lean-ctx
extension (`native-overlay.yml`) and keeps OMP's own tools. A `git-log` task was added.

| arm | passed | tool errors | top-level tools | first request | context tokens, all runs |
|---|---|---|---|---|---|
| baseline (replace) | 16/16 | 8 | 28 | 33.7k | 756k |
| optimized (additive) | 16/16 | 0 | 13 | 22.2k | 418k |
| native only | 16/16 | 0 | 11 | 21.7k | 405k |

Native only matched the optimized arm within 3% on context tokens. In `git-log` every arm piped the
output through `sort | uniq` itself, so lean-ctx's shell compression never had large output to work on.

## Not covered

- Paseo host tools (absent in headless runs; identical in both arms in Paseo).
- Compaction threshold (needs a 400k-token session).
- Subagent smoke (optimized): `researcher` read `skill://poteto-mode` with `read` and ran a command
  with `ctx_shell`.
- Per-model agent smoke: a project agent with `model: "@haiku"` ran on `claude-haiku-5-5:low`.

## Outcome

Native-only won; lean-ctx was removed in 1046f62 (2026-10-23). The `.bench/` harness lived in the
`feature/omp-workflow-optimize` worktree, which was archived afterwards, so `.bench/run.py` no longer exists.
