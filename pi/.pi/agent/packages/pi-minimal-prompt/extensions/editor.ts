import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
  type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import {
  type EditorTheme,
  type TUI,
  truncateToWidth,
  visibleWidth,
} from "@earendil-works/pi-tui";

const PROMPT = " λ";
const PROMPT_PREFIX = `\x1b[1;38;2;251;241;199m${PROMPT}\x1b[22;39m`;
// A deliberately dark teal companion to Zenbones's cyan accent, for legible status text.
const STATUS_ACCENT_BACKGROUND = "\x1b[48;2;49;76;81m";

const stripAnsi = (text: string): string =>
  text
    .replace(/\x1b\[[0-9;]*m/g, "")
    .replace(/\x1b\][^\x07]*(?:\x07|\x1b\\)/g, "")
    .replace(/\x1b_[^\x07]*\x07/g, "");

function isBorder(line: string): boolean {
  const plain = stripAnsi(line);
  return /^─+$/.test(plain) || /^─*\s*[↑↓]\s+\d+\s+more\s*─*$/.test(plain);
}

function bottomBorderIndex(lines: string[]): number {
  for (let index = lines.length - 1; index > 0; index--) {
    if (isBorder(lines[index] ?? "")) return index;
  }
  return Math.max(0, lines.length - 1);
}

function scrollLabel(line: string): string | undefined {
  return stripAnsi(line).match(/([↑↓]\s+\d+\s+more)/)?.[1];
}

function statusAccentBackground(text: string): string {
  return `${STATUS_ACCENT_BACKGROUND}${text.replace(
    /\x1b\[0m/g,
    `\x1b[0m${STATUS_ACCENT_BACKGROUND}`,
  )}\x1b[49m`;
}

function alignStatus(left: string, right: string, width: number): string {
  let leftText = left;
  let rightText = right;

  if (visibleWidth(rightText) >= width - 1) {
    leftText = "";
    rightText = truncateToWidth(rightText, width - 1, "…");
  } else {
    leftText = truncateToWidth(
      leftText,
      Math.max(0, width - visibleWidth(rightText) - 1),
      "…",
    );
  }

  const padding = " ".repeat(
    Math.max(1, width - visibleWidth(leftText) - visibleWidth(rightText)),
  );
  return truncateToWidth(leftText + padding + rightText, width, "");
}

class StatusEditor extends CustomEditor {
  constructor(
    tui: TUI,
    editorTheme: EditorTheme,
    keybindings: KeybindingsManager,
    private readonly ctx: ExtensionContext,
    private readonly getGitBranch: () => string | null,
  ) {
    super(tui, editorTheme, keybindings, { paddingX: 1 });
  }

  override setPaddingX(_padding: number): void {
    super.setPaddingX(1);
  }

  override render(width: number): string[] {
    const prefixWidth = width >= 4 ? 2 : 0;
    const base = super.render(Math.max(1, width - prefixWidth));
    const bottom = bottomBorderIndex(base);
    const theme = this.ctx.ui.theme;
    const model = this.ctx.model?.id ?? "no model";
    const thinking = this.ctx.thinkingLevel;
    const usage = this.ctx.getContextUsage();
    const context = usage ? `${Math.round(usage.percent)}%` : "";
    const contextColor = (usage?.percent ?? 0) >= 90
      ? "error"
      : (usage?.percent ?? 0) >= 70
        ? "warning"
        : "muted";

    const cost = this.ctx.sessionManager.getBranch().reduce((total, entry) => {
      if (entry.type !== "message" || entry.message.role !== "assistant") return total;
      return total + entry.message.usage.cost.total;
    }, 0);
    const delimiter = theme.fg(contextColor, " · ");
    const modelLabel = [
      theme.fg(contextColor, model),
      thinking !== "off" ? theme.fg(contextColor, thinking) : "",
    ].filter(Boolean).join(delimiter);
    const usageLabel = [
      context ? theme.fg(contextColor, context) : "",
      theme.fg(contextColor, `$${cost.toFixed(3)}`),
    ].filter(Boolean).join(delimiter);
    const viewportLabel = [
      scrollLabel(base[0] ?? ""),
      scrollLabel(base[bottom] ?? ""),
    ].filter(Boolean).join(" · ");
    const leftLabel = [this.getGitBranch(), this.ctx.cwd, viewportLabel]
      .filter(Boolean)
      .map((label) => theme.fg(contextColor, label))
      .join(delimiter);
    const rightLabel = `${usageLabel}${delimiter}${modelLabel}`;
    const status = alignStatus(` ${leftLabel}`, `${rightLabel} `, width);

    const promptLines = base.slice(1, bottom).map((line, index) => {
      const prefix = prefixWidth === 0
        ? ""
        : index === 0
          ? PROMPT_PREFIX
          : "  ";
      const promptLine = truncateToWidth(prefix + line, width, "");
      const filledPromptLine = promptLine.replace(
        /\x1b\[0m/g,
        `\x1b[0m${theme.getBgAnsi("userMessageBg")}`,
      );
      return theme.bg(
        "userMessageBg",
        filledPromptLine + " ".repeat(Math.max(0, width - visibleWidth(promptLine))),
      );
    });
    const autocompleteLines = base.slice(bottom + 1).map((line) =>
      truncateToWidth(" ".repeat(prefixWidth) + line, width, ""),
    );

    const promptSpacer = theme.bg("userMessageBg", " ".repeat(width));

    return [
      statusAccentBackground(status),
      promptSpacer,
      ...promptLines,
      ...autocompleteLines,
      promptSpacer,
    ];
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerMarkdownTransformer((markdown, { messageType }) =>
    messageType === "user" ? ` **λ** ${markdown}` : markdown
  );

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    let getGitBranch = (): string | null => null;
    ctx.ui.setFooter((tui, _theme, footerData) => {
      getGitBranch = () => footerData.getGitBranch();
      return {
        render: () => [],
        invalidate: () => {},
        dispose: footerData.onBranchChange(() => tui.requestRender()),
      };
    });
    ctx.ui.setEditorComponent((tui, theme, keybindings) =>
      new StatusEditor(tui, theme, keybindings, ctx, () => getGitBranch()),
    );
  });
}
