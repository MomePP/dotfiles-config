## Build load → one heavy job at a time on this Mac

The work is sized for a MacBook Air 13" M4 with 16 GB of RAM and no fan. On
2026-11-22, the 24 GB Air before it already ran short with several agents:
about 20 GB of app memory, 9 GB held compressed and about 43 GB swapped out
over 8 days. The peaks came from parallel builds, about 10 compiler processes
at 0.7 GB each, plus `cppcheck` at 1.3 GB.

- Run every heavy job under the shared lock:
  `flock /tmp/gogo-build.flock <command>`. Heavy means any firmware or C++
  build (`pio run`, `pio check`, `cmake --build`, `make`, `cargo build`),
  any render or emulator run, and any full test suite that compiles. The
  lock waits its turn and frees itself when the command ends or dies.
  `flock` is the OMP shell builtin; nothing to install.
- Cap parallel jobs at 4: `pio run -j 4`, `make -j4`, `cmake --build . -j 4`,
  `cargo build -j 4`.
- Host tests that compile one file at a time, a lint, or a single `g++` need
  no lock.
- Never hold the lock across a wait, a sleep or a question to the user.
  Batch your checks so you take the lock once.
- At most two working agents at a time, and at most two helper subagents
  each.
- Pass these rules to every subagent you brief; OMP subagents don't receive
  this file.
