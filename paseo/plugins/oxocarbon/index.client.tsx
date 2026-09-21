// Oxocarbon for Paseo's theme picker.
//
// This exists so paseo-repatch does not have to carry the palette. The script
// used to rewrite Paseo's default dark theme in the renderer bundle, which
// replaced a theme rather than adding one, and needed an anchor that could
// break on any release. `addTheme` is Paseo's own API: the theme appears under
// Settings -> Appearance beside the built-ins, survives updates, and can be
// switched away from.
//
// Paseo expands these eight into the full token set. The mapping is not by
// name — read off the bundle's own `buildDarkSemanticColors` call, which is
// what decides how a value reads on screen:
//
//   surface0 = background      the window fill
//   surface1 = raised          panes and cards — and, in sidebar scope, the
//                              whole content pane, so this is the value that
//                              sets how bright the app looks
//   surface2 = control         inputs, popovers, menus
//   surface3 = border
//   surface4 = ring
//   surfaceSidebar = background
//   foregroundMuted = mutedForeground, foregroundExtraMuted = ring
//
// `raised` is therefore the brightness knob, not `background`. Oxocarbon's own
// second step is #262626, which lands ~8 points above the built-in dark
// theme's surface1 (#1E2120) and read noticeably brighter across a full pane.
// #1c1c1c is the palette's subtle step — what the repatch script uses for
// surfaceDiffEmpty — and keeps a visible edge between pane and card without
// lifting the whole window. Set it back to #262626 for more separation, or to
// #161616 to make the pane vanish into the background entirely.
//
// The terminal's 16 ANSI colours are NOT part of this. `addTheme` covers app
// chrome only, so OXOCARBON_ANSI stays a bundle patch in paseo-repatch — and
// has to, since a terminal should keep its palette whatever the chrome wears.
//
// Values are oxocarbon.nvim's, matching superset/oxocarbon-glass.json so Paseo,
// nvim and Superset agree.
import type { PluginClientContext } from "@getpaseo/plugin/client";

export default function contribute(client: PluginClientContext) {
  client.addTheme({
    id: "oxocarbon",
    name: "Oxocarbon",
    appearance: "dark",
    colors: {
      background: "#161616",
      foreground: "#f2f4f8",
      raised: "#1c1c1c",
      control: "#393939",
      border: "#393939",
      accent: "#c693ff",
      mutedForeground: "#8d8d8d",
      ring: "#525252",
    },
  });

  return () => {};
}
