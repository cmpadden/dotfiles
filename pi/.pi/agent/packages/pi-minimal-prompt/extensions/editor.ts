import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
  type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import { homedir } from "node:os";
import {
  type EditorTheme,
  type TUI,
  truncateToWidth,
  visibleWidth,
} from "@earendil-works/pi-tui";

const PROMPT = " λ";
// Dracula+ colors shared with the Bash prompt and Ghostty theme.
const PROMPT_PREFIX = `\x1b[1;38;2;248;248;242m${PROMPT}\x1b[22;39m`;
const STATUS_BACKGROUND = "\x1b[48;2;40;42;54m";
const STATUS_WHITE = "\x1b[38;2;248;248;242m";
const STATUS_RED = "\x1b[38;2;255;110;110m";
const STATUS_CYAN = "\x1b[38;2;139;233;253m";
const HOME_DIRECTORY = homedir();

function displayPath(path: string): string {
  if (path === HOME_DIRECTORY) return "~";
  return path.startsWith(`${HOME_DIRECTORY}/`)
    ? `~${path.slice(HOME_DIRECTORY.length)}`
    : path;
}

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

function statusForeground(color: string, text: string): string {
  return `${color}${text}\x1b[39m`;
}

function statusBackground(text: string): string {
  return `${STATUS_BACKGROUND}${text.replace(
    /\x1b\[0m/g,
    `\x1b[0m${STATUS_BACKGROUND}`,
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
    const contextForeground = (usage?.percent ?? 0) >= 90
      ? STATUS_RED
      : STATUS_WHITE;

    const cost = this.ctx.sessionManager.getBranch().reduce((total, entry) => {
      if (entry.type !== "message" || entry.message.role !== "assistant") return total;
      return total + entry.message.usage.cost.total;
    }, 0);
    const delimiter = statusForeground(STATUS_WHITE, " · ");
    const modelLabel = [
      statusForeground(STATUS_WHITE, model),
      statusForeground(STATUS_WHITE, thinking),
    ].filter(Boolean).join(delimiter);
    const usageLabel = [
      context ? statusForeground(contextForeground, context) : "",
      statusForeground(STATUS_WHITE, `$${cost.toFixed(3)}`),
    ].filter(Boolean).join(delimiter);
    const viewportLabel = [
      scrollLabel(base[0] ?? ""),
      scrollLabel(base[bottom] ?? ""),
    ].filter(Boolean).join(" · ");
    const sessionId = this.ctx.sessionManager.getSessionId();
    const gitBranch = this.getGitBranch();
    const leftLabel = [
      gitBranch ? statusForeground(STATUS_CYAN, gitBranch) : "",
      this.ctx.cwd ? statusForeground(STATUS_WHITE, displayPath(this.ctx.cwd)) : "",
      viewportLabel ? statusForeground(STATUS_WHITE, viewportLabel) : "",
    ].filter(Boolean).join(delimiter);
    const rightLabel = [
      sessionId ? statusForeground(STATUS_WHITE, sessionId) : "",
      usageLabel,
      modelLabel,
    ].filter(Boolean).join(delimiter);
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
      statusBackground(status),
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
