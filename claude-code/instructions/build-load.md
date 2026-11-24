## Build load → at most two heavy jobs at a time on this Mac

The work runs on a MacBook Pro M5 with 32 GB of RAM (owner, 2026-11-25:
two heavy jobs and three working agents at once). The 16 GB and 24 GB
MacBook Airs before it ran short with several agents: on 2026-11-22, about
20 GB of app memory, 9 GB held compressed and about 43 GB swapped out over
8 days. The peaks came from parallel builds, about 10 compiler processes at
0.7 GB each, plus `cppcheck` at 1.3 GB.

- Run every heavy job in one of the two shared build slots. Heavy means any
  firmware or C++ build (`pio run`, `pio check`, `cmake --build`, `make`,
  `cargo build`), any render or emulator run, and any full test suite that
  compiles. Take slot 1 if it is free, otherwise wait for slot 2:

  ```bash
  flock -n -E 75 /tmp/gogo-build.flock <command>; [ $? -eq 75 ] && flock /tmp/gogo-build-2.flock <command>
  ```

  A lock frees itself when its command ends or dies. `flock` is the OMP
  shell builtin; nothing to install. It exists only in the tool shell, not
  inside a script run with `bash script.sh`: call `flock` from the tool
  shell around the script, never inside it.
- Cap parallel jobs at 4 per build: `pio run -j 4`, `make -j4`,
  `cmake --build . -j 4`, `cargo build -j 4`.
- Host tests that compile one file at a time, a lint, or a single `g++` need
  no lock.
- Never hold a slot across a wait, a sleep or a question to the user.
  Batch your checks so you take a slot once.
- At most three working agents at a time, and at most two helper subagents
  each.
- Pass these rules to every subagent you brief; OMP subagents don't receive
  this file.
