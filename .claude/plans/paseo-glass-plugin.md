# Paseo Glass plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `bin/paseo-repatch` and its `brew` hook with one Paseo plugin, `paseo/plugins/glass`, that fetches and verifies Paseo releases, builds the ad-hoc-signed `~/Applications/Paseo-Vibrancy.app` with every current patch, and offers live MonoCode-style glass controls.

**Architecture:** Server side (daemon subprocess, full Node) ports the Python patches to TypeScript, adds a GitHub release fetcher with signature verification, a staging builder, and a detached swap helper. A generated main-process hook (`pg.js` + `blur.node`) inside the copy applies material / CGS blur and watches `paseo-glass.json`. The client contributes Settings → Glass, applies tint and pane glass as CSS variables, and talks to the server over plugin RPC.

**Tech Stack:** TypeScript, `@getpaseo/plugin@0.11.0-beta.3` (`defineRpc`, `useRpc`, `addSettingsScreen`, `SettingsSelect`/`SettingsSwitch`), zod, Node 24 (`node:test`, native type stripping), macOS `codesign`/`ditto`/`PlistBuddy`/`clang`/`osascript`.

**Spec:** `.claude/specs/paseo-glass-plugin-design.md`

## Global Constraints

- Plugin path: `/Users/momeppkt/.config/paseo/plugins/glass`; manifest `{ "id": "glass", "requirements": { "paseo": ">=0.11.0-beta.3" } }`.
- Code lives only in `index.client.tsx`, `index.server.ts`, `client/`, `server/`, `shared/`; tests in `test/`. No `node:` import reachable from client code; `shared/` holds zod schemas and plain values only.
- Relative imports carry the `.ts`/`.tsx` extension (Node runs tests by stripping types; tsconfig sets `allowImportingTsExtensions`, `noEmit`).
- Tests: `npm test` = `node --test test/`; typecheck: `npm run typecheck`.
- Patched copy: `~/Applications/Paseo-Vibrancy.app`; staging: `~/Applications/.Paseo-Vibrancy.staging.app`; release cache: `~/Library/Caches/paseo-glass/`; live settings file: `~/Library/Application Support/Paseo/paseo-glass.json`. Every server function takes these as parameters with these as defaults, so tests use temp dirs.
- Asar hook line (79 bytes, space-padded into the 80-byte anchor): `transparent:require(process.resourcesPath+"/pg.js"),visualEffectState:"active",`
- Glass defaults: `{ material: "none", blurRadius: 30, tint: 0.85, paneGlass: true }`; blur 0–60, tint 0–1.
- Paseo designated requirement (verbatim): `identifier "sh.paseo.desktop" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] and certificate leaf[field.1.2.840.113635.100.6.1.13] and certificate leaf[subject.OU] = "99ZMJMKU9Y"`.
- Release feed: `https://api.github.com/repos/getpaseo/paseo/releases?per_page=20`, assets `beta-mac.yml` then `latest-mac.yml`, entry `Paseo-<ver>-arm64.zip`; `rolloutHours` ignored.
- **Never restart Paseo or its daemon during execution** — it kills the executing agent. All builds before Task 10 use temp targets or `restart: false`. Plugin source changes load with `paseo plugin reload glass`, never a daemon restart.
- Port Python regexes verbatim from `bin/paseo-repatch` (same anchors, counts, labels). Translation rules: `\1` → `$1` in replacement strings; Python lambda replacements → JS replacer functions; counts via `[...src.matchAll(re)]` with the `g` flag; no `s` flag (Python patterns run without DOTALL).

## Review Focus

1. **A new Paseo release moves an anchor** → the build still completes, the report lists `MISSED <label>`, and the Glass screen shows it; a count mismatch fails the build with the label and leaves the installed copy untouched. Tests: Task 2 (`throws PatchCountError`), Task 6 (`failed build leaves target untouched`).
2. **Hand-edited or corrupt `paseo-glass.json`** → `pg.js` falls back to defaults and never throws in Paseo's main process (a throw there breaks app launch). Test: Task 4 (`corrupt settings file falls back to defaults`).
3. **Interrupted build or download** (network drop, disk full, sha mismatch) → nothing half-built is ever swapped in: swap refuses a staging copy without a stamp. Tests: Task 5 (`rejects sha512 mismatch`), Task 7 (`refuses staging without stamp`).
4. **GitHub unreachable or rate-limited (60 req/h unauthenticated)** → `checkUpdate` returns `{ error }` instead of throwing; the screen shows it and Rebuild still works from cache. Test: Task 5 (`network failure yields error result`).
5. **Double-clicking Rebuild** → second build is rejected with "build already running", not a second concurrent write into staging. Test: Task 8 (`concurrent build is rejected`).

---

### Task 1: Plugin scaffold, glass settings schema, RPC contracts

**Files:**
- Create: `paseo/plugins/glass/{paseo-plugin.json,package.json,tsconfig.json}`
- Create: `paseo/plugins/glass/shared/glass.ts`, `paseo/plugins/glass/shared/rpc.ts`
- Test: `paseo/plugins/glass/test/glass-schema.test.ts`

**Interfaces:**
- Produces (`shared/glass.ts`): `MATERIALS` (readonly tuple: `"none","sidebar","hud","under-window","fullscreen-ui","menu","popover","titlebar","header","sheet","window","content","under-page","selection","tooltip"`), `GlassSettingsSchema` (zod object with `.catch` defaults per field), `type GlassSettings`, `GLASS_DEFAULTS`, `parseGlass(raw: unknown): GlassSettings` (never throws).
- Produces (`shared/rpc.ts`, all via `defineRpc`): `statusRpc` (in `{}`; out `{ runningVersion: string|null, runningGlassBuild: boolean, builtFrom: string|null, fingerprintMatches: boolean, latest: Release|null, lastReport: string[], building: boolean }`), `checkUpdateRpc` (out `{ release: Release|null, error: string|null }`), `buildRpc` (in `{ version?: string, restart: boolean }`; out `{ ok: boolean, report: string[], error: string|null }`), `getGlassRpc` / `setGlassRpc` (GlassSettings in/out). `ReleaseSchema = { version, zipUrl, sha512, size }`.

- [ ] **Step 1: Scaffold.** `package.json` mirrors `paseo/plugins/oxocarbon/package.json` with name `paseo-plugin-glass`, devDeps `@getpaseo/plugin@0.11.0-beta.3`, the `zod` version that SDK depends on, `react@19.1.0`, `@types/react@~19.2.0`, `typescript@^5.9.3`, `@types/node`; scripts `typecheck: tsc --noEmit`, `test: node --test test/`. Run `npm install`.
- [ ] **Step 2: Write failing tests** `parseGlass({})` deep-equals `GLASS_DEFAULTS`; `parseGlass({blurRadius: 200, tint: -1})` gives `blurRadius: 60, tint: 0`; `parseGlass({material: "bogus"})` gives `material: "none"`; `parseGlass("not json")` gives defaults.
- [ ] **Step 3: Run** `npm test` → FAIL (module missing).
- [ ] **Step 4: Implement** `shared/glass.ts` (clamp via `z.number().transform`) and `shared/rpc.ts`.
- [ ] **Step 5: Run** `npm test && npm run typecheck` → PASS.
- [ ] **Step 6: Commit** `feat(paseo-glass): scaffold plugin with glass settings and rpc contracts`.

### Task 2: Patch engine and asar patch

**Files:**
- Create: `paseo/plugins/glass/server/patch-engine.ts`, `paseo/plugins/glass/server/asar.ts`
- Test: `paseo/plugins/glass/test/patch-engine.test.ts`

**Interfaces:**
- Produces: `class PatchCountError extends Error { label; expected; found }`; `class Patcher { constructor(src: string); src: string; notes: string[]; replace(label, old: string, neu: string, expect: number): void; replaceRe(label, re: RegExp, neu: string | ((...m: string[]) => string), expect: number): void; sweepRe(label, re: RegExp, neu): void }` — semantics of `replace`/`replace_re`/`sweep_re` in `bin/paseo-repatch:1051-1086` (0 hits → `MISSED  <label>: target not found` / `no matching styles`; wrong count → throw; ok → `ok      <label> (Nx)`).
- Produces: `ASAR_HOOK_ANCHOR` (the 80-byte stock string), `ASAR_HOOK_LINE` (Global Constraints), `patchAsar(data: Buffer): { data: Buffer; notes: string[] }` — same-length replace, pads with spaces, throws if the output length differs or the line is longer than the anchor.

- [ ] **Step 1: Failing tests:** `replaceRe` with 0 hits adds a `MISSED` note and leaves `src`; with 2 hits and `expect 1` throws `PatchCountError` whose `label` is the given label; `sweepRe` reports `(3x)`; `patchAsar` on `Buffer.from("xx"+ASAR_HOOK_ANCHOR+"yy")` returns same length, contains `ASAR_HOOK_LINE`, ends with `" yy"`; `patchAsar` on a buffer without the anchor returns it unchanged with a `MISSED` note; `ASAR_HOOK_LINE.length === 79`.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(paseo-glass): port the patch engine and same-length asar patch`.

### Task 3: Renderer and index.html patches (port + parity)

**Files:**
- Create: `paseo/plugins/glass/server/renderer-patches.ts` (every table/constant from `bin/paseo-repatch` lines 145–860 used by `patch_renderer`/`patch_index_html`, ported verbatim per Global Constraints), `paseo/plugins/glass/server/ghostty.ts`, `paseo/plugins/glass/server/patch-renderer.ts`
- Test: `paseo/plugins/glass/test/ghostty.test.ts`, `paseo/plugins/glass/test/patch-renderer.test.ts`

**Interfaces:**
- Consumes: `Patcher` (Task 2).
- Produces: `type TermMetrics = { fontSize: number|null; lineHeight: number; padding: string; cursorStyle: string; fontFamily: string|null; fontWeight: number|string|null; fontWeightBold: number|string|null }`; `readGhostty(path: string): Record<string,string[]>`; `ghosttyMetrics(cfg): { metrics: Partial<TermMetrics>; notes: string[] }`; `resolveTerm(ghosttyPath?: string): { term: TermMetrics; notes: string[] }` (constants FONT_SIZE 13.5, LINE_HEIGHT 1.1, PADDING `"0 0 0 10px"`, CURSOR_STYLE `"bar"`, FONT_FAMILY null, weights 400/600, Ghostty overrides as in `main()`).
- Produces: `rendererPath(app: string): string`; `patchRenderer(src: string, term: TermMetrics): { src: string; notes: string[] }`; `patchIndexHtml(html: string, padding: string): { html: string; notes: string[] }`; `BUILD_TABLES` (every table and constant, exported for the fingerprint in Task 6).
- Changes vs. Python, all fixed: look is always glass/full/oxocarbon-ANSI/no-palette; `ALPHAS` all 0; navigator backdrop → `background:var(--paseo-pane-bg, transparent)`; scrim table built with pane value `"var(--paseo-pane-bg, transparent)"`; flash-guard rule → `body { background-color: color-mix(in srgb, var(--colors-surface1, #<stock hex>) calc(var(--paseo-tint, 0.85) * 100%), transparent);`; opaque-surfaces style id renamed to `paseo-glass-opaque-surfaces`. The vibrancy/`window_options` code is not ported.

- [ ] **Step 1: Failing tests:** `ghosttyMetrics` on `{ "font-style-bold": ["SemiBold"], "adjust-cell-height": ["8%"], "cursor-style": ["block"] }` → `fontWeightBold 600, lineHeight 1.08, cursorStyle "block"`; `"adjust-cell-height": ["2px"]` → no lineHeight, one note; `patchIndexHtml` on `"<head><style>html,\n body { background-color: #181b1a; }</style></head>"` yields the exact color-mix rule with `#181b1a` and injects the style block before `</head>`; `patchRenderer` on `"x background:'rgb(242, 242, 242)' y"` contains `background:var(--paseo-pane-bg, transparent)`.
- [ ] **Step 2: Run** → FAIL. **Step 3: Implement.** **Step 4: Run** → PASS.
- [ ] **Step 5: Parity check (throwaway, not committed).** Extract a pristine beta.3 (`ditto -x -k ~/Library/Caches/@getpaseodesktop-updater/pending/Paseo-0.11.0-beta.3-arm64.zip /tmp/glass-parity/py` and again into `/tmp/glass-parity/ts`). Run Python `patch_renderer(..., dict(LOOKS["glass"], scope="full"), term, "oxocarbon")` + `patch_index_html(app, 0.85, padding)` on `py` (exec the script as in `.claude/tmp/check-paseo-anchors.py`, same `term` as `resolveTerm()`), and the TS port on `ts`. `diff` the renderer bundles and `index.html`. Expected: zero `MISSED` on both, and the only differing hunks are the navigator backdrop, the scrim surface0 value and the body wash rule (plus the style id). Any other hunk is a porting bug — fix before committing. `rm -rf /tmp/glass-parity`.
- [ ] **Step 6: Commit** `feat(paseo-glass): port the renderer and index.html patches`.

### Task 4: Main-process hook and blur addon

**Files:**
- Create: `paseo/plugins/glass/server/main-hook.ts`, `paseo/plugins/glass/server/blur.ts`
- Test: `paseo/plugins/glass/test/main-hook.test.ts`, `paseo/plugins/glass/test/blur.test.ts`

**Interfaces:**
- Produces: `PG_JS: string` — CommonJS source written to `Contents/Resources/pg.js`. Behaviour: `require("electron")`; reads `path.join(app.getPath("userData"), "paseo-glass.json")` with the same clamping/defaults as `parseGlass` (inlined, no imports — it runs outside the plugin), wrapped so any error falls back to defaults; loads `./blur.node` via `process.dlopen` in try/catch (missing → blur no-op); `apply(win)`: material ≠ `none` → `setVibrancy(material)` + `setBlur(handle, 0)`, else `setVibrancy(null)` + `setBlur(win.getNativeWindowHandle(), blurRadius)`; on `browser-window-created` apply; `fs.watch` on the directory filtered to the file name, debounced 50 ms, re-reads and applies to `BrowserWindow.getAllWindows()`; ends with `module.exports = true`.
- Produces: `BLUR_M: string` (Objective-C; exports `napi_register_module_v1` setting `setBlur(buffer, int)`; N-API prototypes declared by hand; `CGSMainConnectionID`/`CGSSetWindowBackgroundBlurRadius` via `dlsym`, missing → return false; reads the `NSView*` from the buffer, applies to `[view window].windowNumber` on the main thread); `compileBlur(destPath: string): Promise<string /* note */>` — `xcrun clang -bundle -undefined dynamic_lookup -framework AppKit -fobjc-arc -x objective-c -o dest -` with source on stdin; failure → `MISSED  window blur: <reason>`, success → `ok      window blur (compiled)`.

- [ ] **Step 1: Failing tests (`main-hook.test.ts`)**, evaluating `PG_JS` with `vm` and a fake `require` (fake electron `app.getPath`, `app.on`, `BrowserWindow.getAllWindows`, fake windows recording `setVibrancy` calls; fake `process.dlopen` recording `setBlur`):
  - `applies blur 30 with no material by default` (no settings file): new window → `setVibrancy(null)`, `setBlur(_, 30)`.
  - `material switches off blur`: file `{material:"hud"}` → `setVibrancy("hud")`, `setBlur(_, 0)`.
  - `corrupt settings file falls back to defaults`: file `"{nope"` → no throw, defaults applied.
  - `file change re-applies to open windows`: write new file, await 100 ms → latest call `setVibrancy("sidebar")`.
  - `module export is true`.
- [ ] **Step 2: Failing test (`blur.test.ts`):** `compileBlur(tmp/blur.node)` returns an `ok` note; `process.dlopen(m, path)` in plain Node gives `typeof m.exports.setBlur === "function"`; `m.exports.setBlur(Buffer.alloc(8), 30)` returns `false` without crashing.
- [ ] **Step 3: Run** → FAIL. **Step 4: Implement.** **Step 5: Run** → PASS.
- [ ] **Step 6: Commit** `feat(paseo-glass): main-process glass hook and CGS blur addon`.

### Task 5: Release fetch and verification

**Files:**
- Create: `paseo/plugins/glass/server/release.ts`
- Test: `paseo/plugins/glass/test/release.test.ts`

**Interfaces:**
- Consumes: `ReleaseSchema` (Task 1).
- Produces: `compareVersions(a: string, b: string): number` (semver incl. prerelease numeric parts: `0.11.0-beta.3 < 0.11.0-beta.10 < 0.11.0`); `pickLatest(releases: GithubRelease[]): GithubRelease|null` (skip drafts, include prereleases); `parseMacYml(text: string, version: string, zipBaseUrl: string): Release` (arm64 zip entry); `type FeedOpts = { fetch?: typeof fetch; apiUrl?: string /* default https://api.github.com/repos/getpaseo/paseo/releases */ }`; `checkLatest(opts?: FeedOpts): Promise<{ release: Release|null; error: string|null }>` (list = `${apiUrl}?per_page=20`); `fetchRelease(version: string, opts?: FeedOpts): Promise<Release>` (`${apiUrl}/tags/v${version}`). Both locate `beta-mac.yml` (else `latest-mac.yml`) and the zip through the release JSON's `assets[].browser_download_url`, never by building URLs, so a local fake feed works by serving its own URLs.
- Produces: `downloadVerified(release: Release, cacheDir = ~/Library/Caches/paseo-glass): Promise<string /* pristine .app path */>` — streams zip, checks size + base64 sha512, `ditto -x -k`, then `verifyPaseoSignature`, renames to `Paseo-<ver>.app`, deletes the zip and older `Paseo-*.app`; any failure removes partial files and throws; `verifyPaseoSignature(app: string): Promise<void>` (`codesign --verify --deep --strict -R=<DR>`); `cachedPristine(version: string, cacheDir?): string|null`.

- [ ] **Step 1: Failing tests:** version ordering above; `pickLatest` over `[{tag_name:"v0.11.0-beta.4",draft:true},{tag_name:"v0.11.0-beta.3",prerelease:true},{tag_name:"v0.10.2"}]` → the release with `tag_name` `"v0.11.0-beta.3"`; `parseMacYml` on the real beta.3 yml text (spec facts) → `zipUrl` ends `Paseo-0.11.0-beta.3-arm64.zip`, `size 179110962`; `network failure yields error result` (fetch rejecting) → `{release:null, error: /…/}`; `rejects sha512 mismatch` (local `http.createServer` serving a tiny zip, wrong sha) → throws, cache dir has no leftovers; `rejects non-Paseo signature` → `verifyPaseoSignature("/System/Applications/Calculator.app")` rejects.
- [ ] **Step 2: Run** → FAIL. **Step 3: Implement.** **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(paseo-glass): fetch and verify Paseo releases`.

### Task 6: Staging builder

**Files:**
- Create: `paseo/plugins/glass/server/build.ts`
- Test: `paseo/plugins/glass/test/build.test.ts`

**Interfaces:**
- Consumes: `patchAsar` (2), `rendererPath`/`patchRenderer`/`patchIndexHtml`/`resolveTerm`/`BUILD_TABLES` (3), `PG_JS`/`BLUR_M`/`compileBlur` (4).
- Produces: `buildFingerprint(term: TermMetrics): string` (sha256, first 12 hex, over `BUILD_TABLES` serialised with regex `.source`/flags, `ASAR_HOOK_LINE`, `PG_JS`, `BLUR_M`, `term`) — replaces the spec's "hash of server sources" with the same effect: any patch or hook edit changes it; `STAMP_NAME = ".glass-build"`; `stampFor(version, fingerprint): string` = `${version}|glass=${fingerprint}`; `appVersion(app): string` (`CFBundleShortVersionString`); `buildStaging(opts: { source: string; staging?: string; ghosttyPath?: string }): Promise<{ report: string[]; missed: boolean }>` — steps 1–6 of the spec's Build section, in order: `ditto` source → staging (remove old staging first), asar, renderer + html, write `pg.js`, compile `blur.node` into `Contents/Resources`, `app-update.yml` → dead provider (text from `DEAD_UPDATE_YML`, wording updated to name the plugin), PlistBuddy asar hash, stamp written **last before signing** (`want` + `\nmissed` when any MISSED), `codesign --force --deep --sign -`. On any thrown error: delete staging, rethrow.

- [ ] **Step 1: Failing tests:** `fingerprint changes with term` (lineHeight 1.08 vs 1.1 differ); `stampFor("0.11.0-beta.3","abc") === "0.11.0-beta.3|glass=abc"`; `failed build leaves target untouched` (source = temp dir lacking `app.asar` → rejects, staging path does not exist); `builds pristine beta.3 cleanly` — runs only when `GLASS_PRISTINE` env points at a verified pristine app (skip otherwise): report has no `MISSED`, `codesign --verify --deep` on staging exits 0, `Contents/Resources/pg.js` and `blur.node` exist, stamp starts with `0.11.0-beta.3|glass=`.
- [ ] **Step 2: Run** → FAIL. **Step 3: Implement.**
- [ ] **Step 4: Run** `npm test` and once with `GLASS_PRISTINE=<extracted beta.3>` and `staging` pointed at a temp dir → PASS.
- [ ] **Step 5: Commit** `feat(paseo-glass): build the signed staging copy`.

### Task 7: Swap helper

**Files:**
- Create: `paseo/plugins/glass/server/swap.ts`
- Test: `paseo/plugins/glass/test/swap.test.ts`

**Interfaces:**
- Consumes: `STAMP_NAME` (6).
- Produces: `type SwapOpts = { staging: string; target: string; trashDir: string; quit: boolean; open: boolean }`; `swapScript(opts: SwapOpts): string` (POSIX sh: if `quit`, `osascript` quit by bundle id `sh.paseo.desktop` then wait up to 20 s for `pgrep -f "^<target>/Contents/MacOS/Paseo$"` to clear, else exit 1 leaving everything; `mv target trashDir/Paseo-Vibrancy-<epoch>.app` when target exists; `mv staging target`; if `open`, `open -a target`); `startSwap(opts: Omit<SwapOpts, "trashDir"> & { trashDir?: string /* default ~/.Trash */ }): void` — throws `"staging has no build stamp"` when `staging/Contents/Resources/.glass-build` is absent (a stamp ending in `missed` is still swappable: MISSED patches are cosmetic), else `spawn("/bin/sh", ["-c", script], { detached: true, stdio: "ignore" }).unref()`.

- [ ] **Step 1: Failing tests** (temp dirs, `quit:false, open:false`, `startSwap` then poll ≤ 2 s): `swaps staging into target and trashes old` (target holds staging's marker file; trash dir holds one `Paseo-Vibrancy-*.app`); `refuses staging without stamp` (throws, nothing moved); `works when target does not exist yet` (first install).
- [ ] **Step 2: Run** → FAIL. **Step 3: Implement.** **Step 4: Run** → PASS.
- [ ] **Step 5: Commit** `feat(paseo-glass): detached swap-and-relaunch helper`.

### Task 8: Server entry, status, live settings file

**Files:**
- Create: `paseo/plugins/glass/index.server.ts`, `paseo/plugins/glass/server/status.ts`, `paseo/plugins/glass/server/glass-file.ts`
- Test: `paseo/plugins/glass/test/server.test.ts`

**Interfaces:**
- Consumes: Tasks 1, 5, 6, 7.
- Produces: `readGlass(file?): GlassSettings` (via `parseGlass`), `writeGlass(s, file?)` (atomic: write `.tmp`, rename — `pg.js` must never read a half-written file); `runningBundle(execPath = process.execPath): string|null` (outermost `*.app` in the path); `isGlassBuild(bundle): boolean` (stamp present); `class BuildQueue { run<T>(fn: () => Promise<T>): Promise<T> }` rejecting with `"build already running"` while busy; handlers registered with `server.handle` for every contract in `shared/rpc.ts`. `build` flow: `version` = input ?? running version (client passes the latest version for "Update", nothing for "Rebuild"); source = `cachedPristine(version)` ?? `downloadVerified(await fetchRelease(version))`; `buildStaging`; keep `lastReport`; if `restart`, `startSwap({ quit: true, open: true })`. The spec's "copy the running bundle if pristine" bootstrap is dropped: the running bundle is always the ad-hoc copy, which never verifies.

- [ ] **Step 1: Failing tests:** `writeGlass` then `readGlass` round-trips; `readGlass` on missing file → defaults; `runningBundle("/Users/x/Applications/Paseo-Vibrancy.app/Contents/Frameworks/Paseo Helper.app/Contents/MacOS/Paseo Helper")` → `/Users/x/Applications/Paseo-Vibrancy.app`; `isGlassBuild` false for a dir without stamp; `concurrent build is rejected` (two `BuildQueue.run` calls with a pending first → second rejects `"build already running"`).
- [ ] **Step 2: Run** → FAIL. **Step 3: Implement.** **Step 4: Run** `npm test && npm run typecheck` → PASS.
- [ ] **Step 5: Commit** `feat(paseo-glass): server rpc handlers, status and live settings file`.

### Task 9: Client — Glass screen, live CSS, update toast

**Files:**
- Create: `paseo/plugins/glass/index.client.tsx`, `paseo/plugins/glass/client/GlassScreen.tsx`, `paseo/plugins/glass/client/RangeRow.tsx`, `paseo/plugins/glass/client/glass-css.ts`
- Test: `paseo/plugins/glass/test/glass-css.test.ts`

**Interfaces:**
- Consumes: contracts and schema (1).
- Produces: `glassCssVars(s: GlassSettings): { "--paseo-tint": string; "--paseo-pane-bg": string }` (`tint` as a plain number string; pane `"transparent"` when `paneGlass`, else `"var(--colors-surface1)"`); `applyGlassCss(s)` sets them on `document.documentElement.style` (guarded for non-web).
- Screen (`addSettingsScreen({ id: "glass", title: "Glass", icon: "Sparkles", Component: GlassScreen })`): **Appearance** card — Material `SettingsSelect` over `MATERIALS`; Blur radius `RangeRow` 0–60 step 1, disabled unless material is `none`; Tint `RangeRow` 0–100 % mapped to 0–1; Main pane glass `SettingsSwitch`. Each change: `applyGlassCss` immediately, `setGlassRpc` debounced 150 ms. When `status.runningGlassBuild` is false, Appearance shows "Not running the Glass build" and is disabled. **Build** card — running version, built-from version, latest release, last report lines (MISSED in `destructive` colour), actions "Check for updates", "Update & restart" (when latest > running), "Rebuild & restart" (always; label notes "restarts Paseo and interrupts running agents"). `RangeRow` renders `<input type="range">` styled from `theme.colors` (track `surface3`, thumb `foreground`).
- `index.client.tsx`: on contribute, `getGlassRpc` → `applyGlassCss`; `statusRpc` → toast "Paseo <ver> available — Update & restart" (opens the Glass screen via `openSettings("glass")`) when `latest` > running, or "Glass rebuild needed" when `!fingerprintMatches`.

- [ ] **Step 1: Failing test:** `glassCssVars({...GLASS_DEFAULTS})` → `{"--paseo-tint":"0.85","--paseo-pane-bg":"transparent"}`; with `paneGlass:false` → pane `"var(--colors-surface1)"`.
- [ ] **Step 2: Run** → FAIL. **Step 3: Implement.** **Step 4: Run** `npm test && npm run typecheck` → PASS.
- [ ] **Step 5: Commit** `feat(paseo-glass): glass settings screen and live css`.

### Task 10: Install, live smoke, cutover

**Files:**
- Modify: `zsh/.zshrc:228-230` (drop the paseo-repatch sentence from the comment), `zsh/.zshrc:243` (delete the `paseo-repatch || true` line)
- Delete: `bin/paseo-repatch`
- Create: `.claude/knowledges/paseo-glass.md`; Delete: `.claude/specs/paseo-glass-plugin-design.md`, `.claude/plans/paseo-glass-plugin.md`
- Modify: memory notes describing paseo-repatch (`memory://root/MEMORY.md` Paseo sections, `memory://root/skills/paseo-repatch-patterns/SKILL.md`) — rewrite to the plugin.

- [ ] **Step 1: Install.** `paseo plugin install /Users/momeppkt/.config/paseo/plugins/glass`; `paseo plugin ls` → `glass` `running`; `paseo plugin logs glass` clean.
- [ ] **Step 2: Staging build from RPC without restart.** From the Glass screen (or `buildRpc` with `restart:false`): report has 0 `MISSED`; `codesign --verify --deep ~/Applications/.Paseo-Vibrancy.staging.app` exits 0.
- [ ] **Step 3: Fake-feed update path (throwaway script, not committed).** Start a local `http.createServer` on 127.0.0.1 serving a releases list and `/tags/v0.11.0-beta.99` whose `assets` point back at itself: a `beta-mac.yml` for `0.11.0-beta.99` and the cached beta.3 zip (`~/Library/Caches/@getpaseodesktop-updater/pending/Paseo-0.11.0-beta.3-arm64.zip`) with its real sha512. In a Node script call `checkLatest({ apiUrl })` → expect `0.11.0-beta.99`; `downloadVerified(release, <temp cache>)` → a verified app; `buildStaging({ source, staging: <temp> })` → 0 `MISSED`. Delete the script and temp dirs.
- [ ] **Step 4: Hand over the restart.** STOP and ask the user to press **Rebuild & restart** (it quits Paseo and the daemon, ending this session). After relaunch the user (or a new session) checks: running build is the glass build; each of Material, Blur radius, Tint, Main pane glass changes the window live; values survive a quit/relaunch; screenshot (≤ 2000 px) against the MonoCode reference.
- [ ] **Step 5: Cutover commit.** Delete `bin/paseo-repatch`, edit `zsh/.zshrc` as listed; promote spec + plan into `.claude/knowledges/paseo-glass.md` (final state: constraints table from the spec, the asar hook line, file locations, release/verification flow, Gatekeeper finding, isolation env vars); `git rm` spec and plan; update memory notes. Commit `refactor(paseo): replace paseo-repatch with the glass plugin`. Tell the user the `paseo` cask can be uninstalled (`brew uninstall --cask paseo`) — do not run it.
