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
        // The transcript document keeps the startup header first, followed by
        // loaded resources and the chat transcript. Preserve the header.
        const root = tui as unknown as {
          children?: Array<{ children?: Array<{ clear?: () => void }> }>;
        };
        const document = root.children?.[0];
        for (const section of document?.children?.slice(1) ?? []) {
          section.clear?.();
        }

        tui.requestRender(true);
        done();
        return { render: () => [], invalidate: () => {} };
      });
    },
  });
}
