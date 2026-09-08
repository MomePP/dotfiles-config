# zig 0.15 cannot build against the macOS 27 SDK

Any project vendoring a `zig@0.15` build step fails on macOS 27
(CLT 27.0.0.0.1786046012) for two independent reasons. Verified 2026-08-14
while building herdr from source; herdr is gone, but the breakage belongs to
zig + the SDK, so it applies to anything else built the same way
(`libghostty-vt` consumers, ghostty source builds, zig-vendoring Rust crates).

Prebuilt releases are unaffected — this only bites `--head` / from-source builds.

## Failure 1 — `INFINITY` undeclared, libc++ sub-compilation fails

```
error: sub-compilation of libcxx failed
  .../zig/libcxx/include/__random/clamp_to_integral.h:47:58:
  note: use of undeclared identifier 'INFINITY'
```

`MacOSX27.sdk/usr/include/math.h:83` only defines `INFINITY` when clang's own
`float.h` does *not* handle the `__need_infinity_nan` protocol — a **clang 21**
feature. zig 0.15.2 ships clang 20 headers, so neither branch defines it.
`MacOSX26.sdk` still had the unconditional `#define INFINITY HUGE_VALF`, which
is why this appears only on 27.

**`SDKROOT` does not help.** zig 0.15 resolves the SDK with
`xcrun --sdk macosx --show-sdk-path`, and the explicit `--sdk` flag makes xcrun
ignore `SDKROOT`:

```
$ SDKROOT=.../MacOSX26.sdk xcrun --show-sdk-path
.../MacOSX26.sdk
$ SDKROOT=.../MacOSX26.sdk xcrun --sdk macosx --show-sdk-path
.../MacOSX.sdk          # -> MacOSX27.0.sdk
```

**Workaround:** turn SIMD off. The C++ SIMD sources (simdutf + highway) are
usually the only reason `-lc++` is linked; with `-Dsimd=false` zig never builds
libc++ at all. For libghostty-vt that is `LIBGHOSTTY_VT_SIMD=false`. Cost is
scalar UTF-8 / codepoint-width scanning.

## Failure 2 — unaligned archive member, `ld` refuses it

```
ld: ignoring archive member 'compiler_rt.o' - 64-bit mach-o not 8-byte aligned
```

Hits any build that links zig's **static** archive rather than the `.dylib`.
zig 0.15's archiver writes members without 8-byte alignment, and the macOS 27
linker treats that as fatal rather than a warning.

**Workaround:** re-archive with Apple's `libtool`, which aligns correctly.
`ar x` extracts with mode 000, so `chmod` before re-archiving:

```bash
mkdir -p .claude/tmp/arx && cd .claude/tmp/arx
ar x <path>/lib<name>.a && chmod 644 *.o
/usr/bin/libtool -static -o <path>/lib<name>.a *.o
```

Then re-run the outer build **reusing the same build dir** so the zig build
script is not re-run — a re-run reinstalls the unaligned `.a` over the fixed
one. For cargo that is `CARGO_BUILD_BUILD_DIR=<dir>`, and it only works while
cargo's failed-build temp dir survives; `$TMPDIR` under `/var/folders/` is
purged periodically. The tell that it was purged is the same `compiler_rt.o`
error coming back.

## When this goes away

- zig 0.16+ ships clang 21 headers → failure 1 gone. Do **not** simply switch a
  0.15-targeting project to `brew install zig` (0.16): build APIs differ, and
  e.g. ghostty 1.3.2's `build.zig` targets the 0.15 API.
- Failure 2 needs either an aligned zig archiver upstream or a build script that
  links the `.dylib` zig already emits.

`zig@0.15` is keg-only: `/opt/homebrew/opt/zig@0.15/bin/zig`, not on PATH.
It currently has no brew dependents (`brew uses --installed zig@0.15` is empty)
— it was kept for the herdr source build and can go once nothing needs it.
