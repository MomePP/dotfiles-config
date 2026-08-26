# Superset transparent window

How `~/Applications/Superset-transparent.app` gets its glass look, and the
non-obvious things that had to be worked out to get there. Built August 2026
against Superset v1.24.2.

Superset ships opaque and has no setting for this — `superset settings list`
has 33 keys and none touch opacity or window appearance, and the theme schema
(`docs.superset.sh/custom-themes`) is only `ui`, `terminal` and `editor`
colours. The capability comes entirely from patching the app bundle.

## The moving parts

| Piece | Where |
| --- | --- |
| patcher + re-signer | `bin/superset-repatch` (symlinked to `~/.local/bin`) |
| the theme | `superset/oxocarbon-glass.json`, imported with `superset settings theme import` |
| runs after upgrades | the `brew` wrapper in `zsh/.zshrc` calls `superset-repatch` |

The patched copy lives beside the Homebrew-managed one rather than replacing
it. A cask upgrade overwrites `/Applications/Superset.app` wholesale, so
patching it in place would be reverted silently and need Gatekeeper satisfied
again each time. `superset-repatch` rebuilds the private copy from the freshly
upgraded original instead, and no-ops silently when the version is unchanged.

## Patching an asar in place

An asar is a JSON header of byte offsets and sizes followed by concatenated
file bodies. **Same-length replacements keep every offset valid**, so a 1.2 GB
archive never has to be extracted and repacked — each replacement is padded
with spaces to match the original byte count. Making a string *longer* is what
you cannot do; plan replacements to fit, e.g. `bg-background` (13) →
`bg-accent` + 4 spaces.

Two seals then have to be re-satisfied, and missing either means the app will
not launch:

1. **`ElectronAsarIntegrity`** in `Info.plist` holds a SHA256 of the asar.
   Update it with **PlistBuddy, not `plutil`** — the key is literally
   `Resources/app.asar`, and `plutil -replace` splits keypaths on `.`, so it
   reads that as two nested keys.
2. **Hardened runtime + Developer ID signature.** Any edit under `Contents/`
   invalidates it; `codesign --force --deep --sign -` re-signs ad-hoc.

Patches are matched by **content anchors, never byte offsets**, so they survive
Superset's code moving between releases. A target that disappears is reported
as `MISSED` and exits 2 rather than shipping a half-patched app.

## The patches

Seven, all same-length byte replacements:

- **window transparency** — replaces the stock opaque `backgroundColor` with
  `transparent: true` plus a `vibrancy` material (or an ARGB tint when there is
  no material). Removing the opaque colour is not optional; it defeats
  `transparent: true` on its own.
- **xterm allowTransparency** — Superset never passes it, so xterm.js falls
  back to `false`, paints the canvas opaque and flattens any rgba
  `terminal.background` against black. The cost of turning it on: xterm
  alpha-blends per cell instead of doing a fast opaque fill, so heavy scrollback
  can get measurably slower.
- **active tab** — `border-input` + **`bg-card`**, keeping the original shape.
- **right-pane inactive tab** — `bg-border/30` → `bg-card`, so Files/Review lose
  the fill the terminal row's inactive tabs never had. Matched together with
  `text-muted-foreground/70`, because `bg-border/30` alone appears 8 times and
  most are *active*-state uses elsewhere.
- **chrome bar background** (×2 patterns) — the tab strip and workspace header
  paint `bg-muted/45 dark:bg-muted/35`, a visible band over the wash. Patched
  rather than zeroing `ui.muted`, which also drives `hover:bg-muted`.
- **host-unreachable overlay** — `WorkspaceHostUnreachableState` ships with *no*
  background class, relying on the pane beneath being opaque. Scoped by anchor
  because that class string appears 9 times across unrelated components.

### `bg-card`, never `bg-background`, for anything meant to match a pane

These are not interchangeable. In the dark theme `ui.background` carries the
whole dim (alpha 0.55), so putting `bg-background` on a tab paints a *second*
dim layer over the strip's and compounds into a darker slab. `card` is alpha 0
in both themes, so tab and pane resolve to the same surface. This is the
compounding trap again, in a single element.

### Do not restyle by analogy

A `TabsTrigger` in the bundle uses `rounded-[7px]`, and it is tempting to treat
that as "how Superset does tabs". It is a different component from the
right-pane Files/Changes/Review row, which is square with an open bottom edge —
the same browser-tab form the workspace tabs already had. Rounding them made
the two rows disagree rather than match, and had to be reverted.

**Read the element, do not infer it.** Every one of these was settled in one
look with DevTools (⌘⌥I, then ⌘⇧C) and guessed wrong at least once beforehand.

## The compounding trap — the thing that cost the most time

**Superset nests `bg-background` inside `bg-background`.** The tab strip, the
tab itself, and the toolbars all paint it, inside parents that also do. Any
alpha below 1 therefore composites with itself: at 0.32 two layers give 0.54
and three give 0.69, so every nested chrome row reads visibly darker than the
pane and the UI looks banded.

This is not a shadow. Time was lost asserting "CSS `box-shadow`" and then
"macOS window shadow" without checking; the DOM inspector settled it in one
look. **Superset's DevTools is enabled** (⌘⌥I — `devTools: false` appears
nowhere in the bundle) and is by far the fastest way to answer "why does this
element look like that".

The fix is to give **every surface alpha 0** and apply the dim as a single
layer instead — on the window when there is no vibrancy material, or through
`ui.background` when there is (see below). The
same trap explains the terminal reading as a darker inset panel: the xterm
canvas sits *inside* the card, so equal alphas were not equal (0.70 over 0.70
composites to ~0.91). `terminal.background` at alpha 0 makes it inherit the
card rather than stack on it.

Consequence worth knowing: with surfaces at 0, **borders and `input` carry all
the structure**, since nothing has fill to separate it from its neighbours.

## Blur is a material, and it always saturates

There is **no blur-radius knob**. Electron exposes the NSVisualEffectView
material and nothing else, and CSS `backdrop-filter` cannot substitute — it
blurs only content painted inside the page, never the desktop behind a
transparent window.

Two things about materials that cost several rounds of trial and error:

- **Every vibrancy material boosts the saturation** of what it blurs. That is
  what "vibrancy" means in the API, and it is why a blurred window looks more
  colourful than the desktop behind it. There is no non-saturating material.
- **Electron silently ignores an alpha `backgroundColor` when a material is
  set.** Setting both looks like it should give ghostty's blur-plus-dim; the
  colour is simply dropped.

The combination that works: **material for the blur, `ui.background` for the
dim.** The theme's root background paints *over* the vibrancy layer from inside
the page, so it both darkens and desaturates the blur — which no window-level
setting can do. Current: `hud` + `rgba(22,22,22,0.55)`.

Keep `card`/`tertiary`/`sidebar` at alpha 0 while doing this, so only one layer
carries alpha. That is what keeps the nested-`bg-background` banding away.

`VIBRANCY`/`TINT` live at the top of `bin/superset-repatch`. The `--vibrancy`
and `--tint` flags are for experimenting only: the `brew` wrapper runs the
script bare, so a flag-chosen value would be lost at the next upgrade. The
stamp records version, material and tint together, so a bare run after
experimenting rebuilds back to the constants.

## Screenshots lie

Capturing a single focused window composites the transparency differently and
makes the app look flat grey. Judge the result from a full-screen capture or
the screen itself.

## Related

Terminal-side fallout from all this lives in [[claude-hud-transparent-terminal]] —
dim spans and OSC 8 links render as opaque boxes once the terminal is
see-through.

## `editor.colors.activeLine` must be set explicitly on a glass theme

The editor's current-line band is derived, not themed by default:
`getEditorTheme()` computes `activeLine: withAlpha(theme.ui.accent, 0.5)`, and
`withAlpha` **replaces** the colour's alpha rather than multiplying it. On an
opaque theme that is harmless — `#262626` becomes `#26262680`, a subtle lift.
On a glass theme it is not: `ui.accent` is deliberately a near-white tint at
6% (`rgba(242, 244, 248, 0.06)`), and forcing alpha to 0.5 turns the active
line into a `#f2f4f880` wash that composites to ~`#838588` and swallows the
syntax colours underneath.

The fix is an explicit override, which `getEditorTheme` spreads verbatim over
the derived palette and never re-alphas:

```json
"editor": { "colors": { "activeLine": "rgba(242, 244, 248, 0.10)" } }
```

Both glass variants carry one (`rgba(55, 71, 79, 0.10)` for the light one).
The opaque variants deliberately do not — their derived value is already fine.

Two consequences worth knowing:

- Any theme that carries an `editor` block gets the **full** derived editor
  palette (every colour and syntax key) snapshotted into the stored theme at
  import time. That is harmless here because `superset-repatch` re-imports
  these files on every run, so the snapshot refreshes with the app.
- There is no separate token for the active-line *gutter*; it shares
  `activeLine`, so fixing one fixes both.
