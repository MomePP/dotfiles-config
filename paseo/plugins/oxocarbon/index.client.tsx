// Oxocarbon for Paseo's theme picker.
//
// This exists so paseo-repatch does not have to carry the palette. The script
// used to rewrite Paseo's default dark theme in the renderer bundle, which
// replaced a theme rather than adding one, and needed an anchor that could
// break on any release. `addTheme` is Paseo's own API: the theme appears under
// Settings -> Appearance beside the built-ins, survives updates, and can be
// switched away from.
//
// Paseo expands these eight colours into the full token set, so the values are
// chosen for what it derives rather than for the slots they are named after:
//
//   background      the window fill, which every surface is layered over
//   raised          panes and cards — oxocarbon's #262626, one step up
//   control         inputs and controls, and what `border` matches
//   accent          the purple the whole palette is identified by
//   mutedForeground secondary text; the extra-muted tier is derived from it
//   ring            focus outlines
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
      raised: "#262626",
      control: "#393939",
      border: "#393939",
      accent: "#c693ff",
      mutedForeground: "#8d8d8d",
      ring: "#525252",
    },
  });

  return () => {};
}
