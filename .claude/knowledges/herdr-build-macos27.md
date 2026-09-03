# Building herdr from source on macOS 27 (zig@0.15 breakage)

`brew install herdr --head` **cannot work** on macOS 27 (CLT 27.0.0.0.1786046012).
Two independent incompatibilities between `zig@0.15.2` and the macOS 27 SDK /
linker both hit the vendored `libghostty-vt` build. Verified 2026-08-14 against
herdr `master` @ `d76657f`.

## Failure 1 — `INFINITY` undeclared, libc++ sub-compilation fails

```
error: sub-compilation of libcxx failed
  .../zig/libcxx/include/__random/clamp_to_integral.h:47:58:
  note: use of undeclared identifier 'INFINITY'
```

`MacOSX27.sdk/usr/include/math.h:83` only defines `INFINITY` when clang's own
`float.h` does *not* handle the new `__need_infinity_nan` protocol:

```c
#if defined(__has_feature) && __has_feature(modules) && __has_include(<float.h>)
#    define __need_infinity_nan
#    include <float.h>          /* SDK expects float.h to define INFINITY/NAN */
#else
#    define NAN __builtin_nanf("0x7fc00000")
#endif

#if !defined(__GNUC__) || !__has_feature(modules) || !__has_include(<float.h>)
#define INFINITY    HUGE_VALF
#endif
```

`__need_infinity_nan` is a **clang 21** feature. zig 0.15.2 ships clang 20
headers (`lib/zig/include/float.h` has no `__need_infinity_nan`), so neither
branch defines `INFINITY`. `MacOSX26.sdk/usr/include/math.h:74` still has the
unconditional `#define INFINITY HUGE_VALF`, which is why this only appears on 27.

**`SDKROOT` does not help.** zig 0.15 resolves the SDK with
`xcrun --sdk macosx --show-sdk-path`, and the explicit `--sdk` flag makes xcrun
ignore `SDKROOT`. Confirmed:

```
$ SDKROOT=.../MacOSX26.sdk xcrun --show-sdk-path
.../MacOSX26.sdk
$ SDKROOT=.../MacOSX26.sdk xcrun --sdk macosx --show-sdk-path
.../MacOSX.sdk          # -> MacOSX27.0.sdk
```

**Workaround:** `LIBGHOSTTY_VT_SIMD=false`. The C++ SIMD sources
(`vendor/libghostty-vt/src/simd/*.cpp`, simdutf + highway) are the only reason
`-lc++` is linked; with `-Dsimd=false` zig never builds libc++ at all.
Cost: scalar UTF-8 / codepoint-width scanning in the VT parser.

## Failure 2 — `ld: ignoring archive member 'compiler_rt.o' - not 8-byte aligned`

With SIMD off, the zig build succeeds and the Rust link then fails:

```
ld: ignoring archive member 'compiler_rt.o' - 64-bit mach-o not 8-byte aligned
   in .../zig-out/lib/libghostty-vt.a
clang: error: linker command failed with exit code 1
```

`build.rs` links the **static** archive on darwin
(`cargo:rustc-link-arg=<...>/libghostty-vt.a`); zig 0.15's archiver writes
members without 8-byte alignment and the macOS 27 `ld` treats that as fatal
rather than a warning.

**Workaround:** re-archive with Apple's `libtool`, which aligns correctly.

## Working recipe

```bash
ZIG=/opt/homebrew/opt/zig@0.15/bin/zig   # keg-only, not on PATH

# 1. First pass: builds libghostty-vt, fails at the Rust link step.
LIBGHOSTTY_VT_SIMD=false ZIG=$ZIG \
  cargo install --git https://github.com/herdrdev/herdr --locked herdr
# note the "intermediate artifacts can be found at <BUILD_DIR>" path it prints

CO=~/.cargo/git/checkouts/herdr-*/<rev>/vendor/libghostty-vt/zig-out/lib

# 2. Re-archive. `ar x` extracts with mode 000 -> chmod before libtool.
mkdir -p .claude/tmp/arx && cd .claude/tmp/arx
ar x $CO/libghostty-vt.a && chmod 644 *.o
/usr/bin/libtool -static -o $CO/libghostty-vt.a compiler_rt.o libghostty-vt-static_zcu.o

# 3. Re-run reusing the same build dir so build.rs is NOT re-run
#    (a re-run makes zig re-install the unaligned .a over the fixed one).
CARGO_BUILD_BUILD_DIR=<BUILD_DIR> LIBGHOSTTY_VT_SIMD=false ZIG=$ZIG \
  cargo install --git https://github.com/herdrdev/herdr --locked herdr
```

Step 3 only works while cargo's failed-build temp dir still exists — cargo keeps
it on failure, but `$TMPDIR` under `/var/folders/` is purged periodically. If it
is gone, step 3 becomes a fresh build, re-runs `build.rs`, and zig re-installs
the unaligned `.a`; the tell is the same `compiler_rt.o` ld error coming back.
Fix: repeat steps 2 and 3 with the new build-dir path.

Installs to `~/.cargo/bin/herdr` (on PATH ahead of any brew copy).
`herdr --version` still reports the crate version (`0.8.0`), not the git rev.

## When this goes away

- zig ships clang 21 headers (0.16+) → failure 1 gone. Do **not** just point
  herdr at `brew install zig` (0.16.0): vendored ghostty 1.3.2's `build.zig`
  targets the 0.15 build API.
- Fixing failure 2 upstream means either an aligned zig archiver or having
  `build.rs` link the `.dylib` it already emits.
- Once the `herdr` formula bumps its `zig@0.15` build dep, drop this and
  `cargo uninstall herdr` before `brew install herdr --head`.
