import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.notify("clear-screen active: Ctrl+L clears the screen, model selector is Ctrl+X.", "info");
  });

  pi.registerShortcut("ctrl+l", {
    description: "Clear screen",
    handler: async (ctx) => {
      if (!ctx.hasUI) return;

      await ctx.ui.custom<void>((tui, _theme, _keybindings, done) => {
        const root = tui as unknown as { children?: Array<{ clear?: () => void }> };
        const chatContainer = root.children?.[1];

        if (chatContainer && typeof chatContainer.clear === "function") {
          chatContainer.clear();
        }

        tui.requestRender(true);
        done();
        return { render: () => [], invalidate: () => {} };
      });
    },
  });
}
