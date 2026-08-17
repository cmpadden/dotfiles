import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const BANNER = `            d8,          d8b                           d8b
           \`8P           88P            d8P            88P
                        d88          d888888P         d88
?88,.d88b,  88b     d888888   d8888b   ?88'       d888888   d8888b?88   d8P
\`?88'  ?88  88P    d8P' ?88  d8P' ?88  88P       d8P' ?88  d8b_,dPd88  d8P'
  88b  d8P d88     88b  ,88b 88b  d88  88b       88b  ,88b 88b    ?8b ,88'
  888888P'd88'     \`?88P'\`88b\`?8888P'  \`?8b      \`?88P'\`88b\`?888P'\`?888P'
  88P'
 d88
 ?8P`;

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setHeader((_tui, theme) => new Text(theme.fg("accent", BANNER), 1, 0));
  });
}
