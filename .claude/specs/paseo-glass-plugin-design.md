# Paseo Glass plugin — design

## Goal

Replace `bin/paseo-repatch` and its `brew` wrapper hook with one Paseo plugin,
`paseo/plugins/glass`, that:

1. builds and maintains the patched copy `~/Applications/Paseo-Vibrancy.app`
   with every patch the script applies today;
2. fetches and verifies new Paseo releases itself (beta channel), so neither
   the stock `/Applications/Paseo.app` nor the brew cask is needed;
3. gives a Settings → **Glass** screen with MonoCode-style live controls:
   material, blur radius, tint, main-pane glass.

Default look matches MonoCode 0.6.0's default translucency: no material,
CGS blur radius 30, 85% tint, glass over the whole window. Palette stays the
Oxocarbon theme (`paseo/plugins/oxocarbon`, unchanged).

## Constraints established by experiment (2026-10-02, Paseo 0.11.0-beta.3)

- **A patched bundle must be re-signed locally.** A copy of the notarized app
  with modified resources and the original signature kept is held at launch by
  Gatekeeper (`GK evaluateScanResult: 3 … Prompt shown`; `spctl`: "a sealed
  resource is missing or invalid"). The unmodified build assesses
  `accepted, Notarized Developer ID`. In-place patching of
  `/Applications/Paseo.app` is therefore out, and so is keeping Paseo's
  in-app updater.
- **`/Applications/Paseo.app` is write-protected** against a non-Paseo
  responsible process (App Management, `EPERM`).
- Hardened runtime without `disable-library-validation`: an unsigned
  `blur.node` only loads because the copy is ad-hoc signed.
- **Server plugins have full Node.** `index.server.ts` is compiled by esbuild
  and run in a forked daemon subprocess with no permission flags; `node:`
  imports are only forbidden from client code.
- Plugins are registered in `~/.paseo/config.json` → `plugins.<id>`
  (`{"source":"directory","path":…,"enabled":true}`), outside the app bundle.
- Release feed: `app-update.yml` is `provider: github`, `getpaseo/paseo`,
  `releaseType: prerelease`, `channel: beta`. Each release carries
  `beta-mac.yml` / `latest-mac.yml` listing `Paseo-<ver>-arm64.zip` with
  `sha512` and `size`.
- Paseo's designated requirement:
  `identifier "sh.paseo.desktop" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] and certificate leaf[field.1.2.840.113635.100.6.1.13] and certificate leaf[subject.OU] = "99ZMJMKU9Y"`.
- `desktop-settings.json` has no `daemon` block, so `keepRunningAfterQuit` is
  the default `false`: quitting the app stops the daemon and its plugin
  subprocesses.
- Isolation for testing a second copy: `PASEO_HOME` (daemon home, set its
  `config.json` listen to a free port) and `PASEO_ELECTRON_USER_DATA_DIR`
  (userData and single-instance lock). `--user-data-dir` is ignored.

## Layout

```text
paseo/plugins/glass/
  paseo-plugin.json        { "id": "glass", "requirements": { "paseo": ">=0.11.0-beta.3" } }
  package.json, tsconfig.json
  index.client.tsx         settings screen, CSS application, update toast
  index.server.ts          registers RPC handlers
  client/                  GlassSettings screen, range slider, CSS applier
  server/                  patches, builder, release fetcher, blur, swap
  shared/                  zod RPC contracts and the glass settings schema
```

### Runtimes

| Part | Runtime | Role |
|---|---|---|
| `index.client.tsx`, `client/` | renderer | Glass screen, live CSS variables, update toast |
| `index.server.ts`, `server/` | daemon subprocess | releases, verification, build, swap, settings file |
| `pg.js` (generated) | Paseo main process | window material/blur, watches settings file |
| `blur.node` (generated) | Paseo main process | `setBlur(handle, radius)` via CGS |

## Live glass settings

Schema (`shared/`), persisted by the server to
`~/Library/Application Support/Paseo/paseo-glass.json`:

```ts
{ material: "none" | "sidebar" | "hud" | "under-window" | "fullscreen-ui"
            | "menu" | "popover" | "titlebar" | "header" | "sheet"
            | "window" | "content" | "under-page" | "selection" | "tooltip",
  blurRadius: number,   // 0–60, used when material is "none"
  tint: number,         // 0–1
  paneGlass: boolean }
```

Defaults: `{ material: "none", blurRadius: 30, tint: 0.85, paneGlass: true }`.

- **Main process** (`pg.js`, written into `Contents/Resources` by the build).
  Loaded by the asar window-options patch
  `transparent:require(process.resourcesPath+"/pg.js"),visualEffectState:"active",`
  (79 bytes into the 80-byte
  `backgroundColor: (0, window_manager_js_1.getWindowBackgroundColor)(systemTheme),`
  slot, space-padded). `pg.js` ends with `module.exports = true`, so the
  `require` yields `transparent: true`. `visualEffectState` has no runtime
  setter in Electron, which is why it rides in the same slot: it keeps a
  material from going flat when the window loses focus, and is read whenever
  `setVibrancy` later creates the effect view. The short filename is what
  makes both fit. `pg.js` reads the settings file, applies it to every window
  on `browser-window-created`, and re-applies on `fs.watch` changes.
  Material ≠ `none`: `win.setVibrancy(material)` and blur 0. Material `none`:
  `win.setVibrancy(null)` and `blur.setBlur(win.getNativeWindowHandle(), r)`.
- **Renderer** (client). On load and on change sets on `document.documentElement`:
  - `--paseo-tint` = tint, consumed by the `body` wash rule:
    `background-color: color-mix(in srgb, var(--colors-surface1, <stock hex>) calc(var(--paseo-tint, <default>) * 100%), transparent);`
  - `--paseo-pane-bg` = `transparent` when `paneGlass`, else
    `var(--colors-surface1)`; consumed by the navigator backdrop patch
    `background:var(--paseo-pane-bg, transparent)`.
- **Glass screen** (`addSettingsScreen({id:"glass", title:"Glass", …})`):
  Appearance card — Material (`SettingsSelect`), Blur radius and Tint
  (`<input type="range">` styled with theme tokens; web-only is fine, the
  patched app is the only consumer), Main pane glass (`SettingsSwitch`). Each
  change calls `setGlass` RPC; tint and pane apply locally at once.
- In stock (unpatched) Paseo the screen shows "Not running the Glass build"
  and only the Build card is active.

## Build and updates

### RPC contracts (`shared/`)

| RPC | Input | Output |
|---|---|---|
| `status` | — | running version, built-from version, plugin hash match, latest known release, last build report |
| `checkUpdate` | — | latest release `{version, zipUrl, sha512, size}` or null |
| `build` | `{ version?: string, restart: boolean }` | build report lines (`ok …` / `MISSED …`) |
| `getGlass` / `setGlass` | settings | settings |

### Release fetch

1. `GET https://api.github.com/repos/getpaseo/paseo/releases?per_page=20`;
   newest non-draft release by semver (prereleases included — beta channel).
2. Fetch the tag's `beta-mac.yml` (fall back to `latest-mac.yml`); take the
   `arm64.zip` entry. `rolloutHours` is ignored.
3. Download to `~/Library/Caches/paseo-glass/`, verify size and `sha512`.
4. `ditto -x -k`, then
   `codesign --verify --deep --strict -R='<designated requirement above>'`.
   Any failure aborts with the reason; nothing is built from it.
5. Keep the verified pristine app as
   `~/Library/Caches/paseo-glass/Paseo-<ver>.app` (build source); delete older
   ones.

Without network, `build` uses the cached pristine app for the running
version. Bootstrap: if no cached source exists, the server copies the running
bundle only if it is a pristine, verifiable Paseo; otherwise it fetches the
release matching the running version.

### Build (into `~/Applications/.Paseo-Vibrancy.staging.app`)

1. `ditto` the pristine source.
2. asar: same-length patches (window options hook line). Length change →
   abort.
3. Renderer bundle (resolved via `index.html`, as today) and `index.html`:
   every current patch, ported verbatim with identical anchors, counts, and
   `MISSED`/sweep semantics — alpha helper, surface alphas, window chrome
   payload, terminal metrics + sync, diff palette, overlay surfaces (annotate
   card, toast pill), frame-rate stepping, readable surface0 foregrounds,
   hover fills, backdrop masks, trailing scrim, kebab chip/gutter, resize
   handle, navigator backdrop (now `var(--paseo-pane-bg, transparent)`),
   oxocarbon ANSI, opaque-surfaces stylesheet + xterm padding, flash-guard →
   tint rule. Build-time inputs stay constants in `server/` (font size 13.5,
   line height, weights 400/600, cursor, padding, ANSI palette), with Ghostty
   derivation from `~/.config/ghostty/config` as today.
4. Write `pg.js`; compile `blur.node`:
   `clang -bundle -undefined dynamic_lookup -framework AppKit -fobjc-arc`.
   N-API symbols declared by hand (`napi_create_function`,
   `napi_set_named_property`, `napi_get_buffer_info`,
   `napi_get_value_int32`); CGS functions via `dlsym`, missing → no-op.
   No clang or compile error → `MISSED window blur: <reason>`; materials keep
   working.
5. `app-update.yml` → dead provider (as today).
6. `PlistBuddy` asar-integrity hash, stamp
   (`<ver>|plugin=<hash of server sources>|<build constants>`), then
   `codesign --force --deep --sign -`.
7. Report: every line returned to the client; any `MISSED` is shown on the
   Glass screen and the build still completes (as today).

### Swap and restart

`build({restart:true})` spawns a detached helper (`detached: true`,
`stdio: "ignore"`, `unref()`), which survives the daemon stopping on quit:
quit the app by executable path (as `quit_patched` does), wait for exit,
move `~/Applications/Paseo-Vibrancy.app` to the Trash, rename staging into
place, `open` it. Running agents are interrupted, as on any Paseo update.
`restart:false` leaves the staging copy for the next manual restart (the
helper swaps on next invocation).

### Update prompt

On client load, `status` + `checkUpdate`; a newer release shows a toast
"Paseo <ver> available — Update & restart" linking to the Glass screen. A
plugin-hash mismatch (plugin edited since the build) shows "Rebuild needed".

## Cutover

1. Port parity: run `bin/paseo-repatch`'s patch functions and the port against
   the same pristine 0.11.0-beta.3; asar, renderer bundle and `index.html`
   must be byte-identical except the hook line, the tint rule and the
   navigator backdrop value.
2. Register the plugin in `~/.paseo/config.json`; Rebuild & restart from the
   GUI.
3. Remove `bin/paseo-repatch` and its line in the `zsh/.zshrc` `brew`
   wrapper (and its comment block); uninstall the `paseo` cask if wanted.
4. Promote spec + plan to `.claude/knowledges/paseo-glass.md`; `git rm` them.
   Update `memory://` notes that describe paseo-repatch.

## Verification

- Parity diff (above) clean.
- `build` report: 0 `MISSED`; `nm -gU blur.node` shows
  `_napi_register_module_v1`; `codesign --verify --deep` on the copy passes.
- Live: each of the four controls visibly changes the running window without
  restart; values survive a restart.
- Update path: a fake feed (local server, newer version pointing at the
  cached beta.3 zip) produces the toast and a full download → verify → build;
  a tampered zip (bad sha512) and a non-Paseo-signed app are both rejected.
- Swap: Rebuild & restart from the GUI relaunches into the new build.
