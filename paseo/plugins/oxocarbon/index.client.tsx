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
// `raised` is therefore the brightness knob, not `background`. oxocarbon.nvim
// derives its dark steps by blending base00 into base06 in HSLuv, not sRGB:
//
//   base00 #161616   base01 #1b1b1b (0.085)   base02 #212121 (0.18)
//   base03 #282828 (0.3)   float_bg #232323   blend #131313
//
// Every one of those steps is meant for a small area — a float, a cursorline.
// Paseo puts surface1 under the entire content pane, and at that size any lift
// above base00 reads as the whole window being brighter: #262626 was 8 points
// above the built-in dark theme's surface1 (#1E2120) and obviously bright,
// #181818 still showed. So base00 itself, and the pane simply is the
// background — which is also what nvim and Ghostty are at.
//
// The cost is that surface1 no longer separates a card from the pane it sits
// on; borders and surface2 have to carry that instead. Set this to #1b1b1b for
// the palette-faithful step back, or #262626 for real card separation.
//
// The terminal's 16 ANSI colours are NOT part of this. `addTheme` covers app
// chrome only, so OXOCARBON_ANSI stays a bundle patch in paseo-repatch — and
// has to, since a terminal should keep its palette whatever the chrome wears.
//
// Values come from ~/Developer/nvim-plugins/oxocarbon.nvim and Ghostty's own
// `oxocarbon` theme (background #161616, foreground #f2f4f8), so Paseo, nvim
// and the terminal agree. Ghostty then runs that background at opacity 0.80,
// which is why its base reads darker than the hex alone.
import type { PluginClientContext } from "@getpaseo/plugin/client";

export default function contribute(client: PluginClientContext) {
  client.addTheme({
    id: "oxocarbon",
    name: "Oxocarbon",
    appearance: "dark",
    colors: {
      background: "#161616",
      foreground: "#f2f4f8",
      raised: "#161616",
      control: "#393939",
      border: "#393939",
      accent: "#c693ff",
      mutedForeground: "#8d8d8d",
      ring: "#525252",
    },
  });

  return () => {};
}
