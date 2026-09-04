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
        // The first section is Pi's startup header. Clear it too, along with
        // resource notices and the transcript, for a genuinely blank screen.
        const root = tui as unknown as {
          children?: Array<{ children?: Array<{ clear?: () => void }> }>;
        };
        const document = root.children?.[0];
        for (const section of document?.children ?? []) {
          section.clear?.();
        }

        tui.requestRender(true);
        done();
        return { render: () => [], invalidate: () => {} };
      });
    },
  });
}
