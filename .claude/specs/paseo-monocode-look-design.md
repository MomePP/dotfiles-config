# Paseo MonoCode look — design

## Goal

Make the patched Paseo (`~/Applications/Paseo-Vibrancy.app`, built by
`bin/paseo-repatch`) read like MonoCode's default glass: a radius-30 window
blur with no material, an 85% theme-coloured tint, and glass across the whole
window (sidebar and main pane). The palette stays Oxocarbon (plugin
`paseo/plugins/oxocarbon`); MonoCode's neutral palette and white accent are
out of scope.

Reference MonoCode settings (0.6.0): Dark, hue 240°, saturation 0%, lightness
9%, sidebar opacity 85%, blur radius 30, main pane glass on.

## Facts this rests on

- MonoCode is Tauri (WKWebView). Its blur slider calls the private
  `CGSSetWindowBackgroundBlurRadius` (resolved with `dlsym`, alongside
  `CGSMainConnectionID` / `CGSDefaultConnectionForThread`). No material.
- Electron exposes only `vibrancy` materials on macOS: no radius, and every
  material boosts saturation. Parity needs native code in Paseo's main process.
- Both CGS symbols resolve from
  `/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics` on the
  current macOS (checked with `ctypes`).
- The asar window-options anchor
  `backgroundColor: (0, window_manager_js_1.getWindowBackgroundColor)(systemTheme),`
  is 80 bytes and is evaluated in the main process when each `BrowserWindow`
  is constructed.
- Paseo 0.11.0-beta.3 fuses: `EnableNodeOptionsEnvironmentVariable` on,
  `OnlyLoadAppFromAsar` off. Main executable has 32 bytes of Mach-O header
  padding.
- `index.html`'s pre-mount rule is `html, body { background-color: #181b1a; }`
  (Paseo's green-grey dark); the current dim reuses that hex.

## Approach

A compiled N-API addon, `Contents/Resources/blur.node`, loaded by the window
options patch the script already makes:

```js
transparent:!process.dlopen({exports:{}},process.resourcesPath+"/blur.node"),
```

77 bytes, fits the 80-byte slot (space-padded as today). `process.dlopen`
returns `undefined`, so `!` yields `transparent: true`.

Rejected:

- `LC_LOAD_DYLIB` into `Contents/MacOS/Paseo`: 32 bytes of header padding is
  too small for any load command with a usable path.
- `NODE_OPTIONS=--require` via `LSEnvironment`: inherited by every shell and
  `node` process in Paseo's terminal.
- `Resources/app/` shim: moves `app.getAppPath()`, which Paseo resolves its own
  resources from.

## Design

### 1. Native blur addon

- Objective-C source (~40 lines) embedded in the script as a string constant,
  compiled at rebuild time:
  `clang -bundle -undefined dynamic_lookup -framework AppKit -fobjc-arc -DBLUR_RADIUS=<n> -o blur.node`.
- Exports `napi_register_module_v1(env, exports)` returning `exports`; no N-API
  headers needed (opaque pointer typedefs).
- A once-guard (static flag) installs:
  - `dispatch_async(dispatch_get_main_queue(), …)` applying blur to every
    window in `NSApp.windows` — runs on the next runloop turn, after the
    `BrowserWindow` being constructed exists;
  - an `NSWindowDidBecomeKeyNotification` observer applying blur to that
    window, covering windows created later.
- Apply = for each `NSWindow` with `isOpaque == NO`:
  `CGSSetWindowBackgroundBlurRadius(CGSMainConnectionID(), windowNumber, BLUR_RADIUS)`.
  Both functions resolved with `dlsym(RTLD_DEFAULT, …)`; missing → no-op.
- Signed ad-hoc (`codesign -s - blur.node`) before the bundle is signed, so
  the bundle signature seals a signed Mach-O.
- Failure handling (all report `MISSED  window blur: <reason>` and the build
  continues with the window transparent and unblurred, plain `transparent: true,`):
  - `blur` set but no clang (`xcrun --find clang` fails);
  - CGS symbols not found via `ctypes` at rebuild time;
  - compile fails.
- A blur look emits no `vibrancy`: the material and a CGS blur do not combine.
  `window_options()` composes from both and is part of the stamp signature.

### 2. Look, defaults, tint

- `LOOKS["monocode"] = {"vibrancy": None, "blur": 30, "dim": 0.85, "palette": False}`;
  other looks gain `"blur": 0`.
- Defaults: `LOOK = "monocode"`, `SCOPE = "full"`. A bare run (and the `brew`
  wrapper) builds this look.
- `--blur-radius N` overrides for one run, `0` = off; help text prints the
  default, like `--dim` / `--vibrancy`. `look_signature()` includes `blur`.
- Wash: the `body` rule written by `patch_index_html()` becomes
  `background-color: color-mix(in srgb, var(--colors-surface1, #181b1a) <dim*100>%, transparent);`
  with the hex taken from the stock rule as today. The tint follows the active
  theme (`#161616` under Oxocarbon) and falls back to the stock colour before
  React mounts.
- Comment blocks (`LOOK`/`VIBRANCY`/`DIM`) and `--help` updated to describe the
  blur option.

## Verification

- Rebuild: zero `MISSED`; `ok window blur` present.
- `nm -gU blur.node` lists `_napi_register_module_v1`.
- `codesign --verify --deep ~/Applications/Paseo-Vibrancy.app` passes.
- `node --check` on the patched renderer (unchanged behaviour there).
- Launch the patched copy; screenshot (resized ≤ 2000px) compared against the
  MonoCode reference: neutral blur without saturation boost, ~85% dark tint
  over sidebar and main pane.
- Bare re-run is a silent no-op (stamp matches).
