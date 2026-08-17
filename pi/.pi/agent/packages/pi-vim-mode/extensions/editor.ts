import {
  CustomEditor,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import {
  matchesKey,
  truncateToWidth,
  type AutocompleteProvider,
  type EditorComponent,
  type TUI,
  visibleWidth,
} from "@earendil-works/pi-tui";

type CursorEditor = EditorComponent & {
  getCursor?: () => { line: number; col: number };
  getLines?: () => string[];
};

type Motion = "left" | "down" | "up" | "right" | "wordBackward" | "wordForward" | "bigWordForward" | "wordEnd" | "bigWordEnd" | "lineStart" | "lineEnd";
type Insert = "cursor" | "after" | "lineStart" | "lineEnd" | "below" | "above";
type DeleteMotion = "line" | "lineStart" | "lineEnd" | "wordBackward" | "bigWordBackward" | "wordForward" | "bigWordForward" | "wordEnd" | "bigWordEnd";

type Command =
  | { kind: "operator"; operator: "delete" }
  | { kind: "insert"; insert: Insert }
  | { kind: "motion"; motion: Motion }
  | { kind: "deleteChar" }
  | { kind: "delete"; motion: DeleteMotion };

type KeyTrie = {
  command?: Command;
  children?: Record<string, KeyTrie>;
};

const command = (value: Command, children?: Record<string, KeyTrie>): KeyTrie => ({
  command: value,
  children,
});

// Prefix nodes express multi-key commands; the parser keeps the current node
// while it collects a count or waits for the remaining key sequence.
const NORMAL_COMMANDS: KeyTrie = {
  children: {
    i: command({ kind: "insert", insert: "cursor" }),
    a: command({ kind: "insert", insert: "after" }),
    I: command({ kind: "insert", insert: "lineStart" }),
    A: command({ kind: "insert", insert: "lineEnd" }),
    o: command({ kind: "insert", insert: "below" }),
    O: command({ kind: "insert", insert: "above" }),
    h: command({ kind: "motion", motion: "left" }),
    j: command({ kind: "motion", motion: "down" }),
    k: command({ kind: "motion", motion: "up" }),
    l: command({ kind: "motion", motion: "right" }),
    b: command({ kind: "motion", motion: "wordBackward" }),
    w: command({ kind: "motion", motion: "wordForward" }),
    W: command({ kind: "motion", motion: "bigWordForward" }),
    e: command({ kind: "motion", motion: "wordEnd" }),
    E: command({ kind: "motion", motion: "bigWordEnd" }),
    "0": command({ kind: "motion", motion: "lineStart" }),
    $: command({ kind: "motion", motion: "lineEnd" }),
    x: command({ kind: "deleteChar" }),
    D: command({ kind: "delete", motion: "lineEnd" }),
    d: command({ kind: "operator", operator: "delete" }, {
      d: command({ kind: "delete", motion: "line" }),
      "0": command({ kind: "delete", motion: "lineStart" }),
      $: command({ kind: "delete", motion: "lineEnd" }),
      b: command({ kind: "delete", motion: "wordBackward" }),
      B: command({ kind: "delete", motion: "bigWordBackward" }),
      w: command({ kind: "delete", motion: "wordForward" }),
      W: command({ kind: "delete", motion: "bigWordForward" }),
      e: command({ kind: "delete", motion: "wordEnd" }),
      E: command({ kind: "delete", motion: "bigWordEnd" }),
    }),
  },
};

const isWhitespace = (char: string): boolean => /\s/.test(char);
const isWordCharacter = (char: string): boolean => /[\p{L}\p{N}_]/u.test(char);
const isCountDigit = (key: string): boolean => /^[1-9]$/.test(key);

type PendingOperator = {
  count: number;
  node: KeyTrie;
  operator: "delete";
};

type AppEditor = EditorComponent & {
  actionHandlers?: Map<unknown, () => void>;
  onEscape?: () => void;
  onCtrlD?: () => void;
  onPasteImage?: () => void;
  onExtensionShortcut?: (data: string) => boolean;
};

class VimEditor implements EditorComponent {
  private mode: "normal" | "insert" = "insert";
  private count = "";
  private pendingOperator: PendingOperator | undefined;

  constructor(
    private readonly tui: TUI,
    private readonly base: EditorComponent,
  ) {}

  get onSubmit(): ((text: string) => void) | undefined {
    return this.base.onSubmit;
  }

  set onSubmit(handler: ((text: string) => void) | undefined) {
    this.base.onSubmit = handler;
  }

  get onChange(): ((text: string) => void) | undefined {
    return this.base.onChange;
  }

  set onChange(handler: ((text: string) => void) | undefined) {
    this.base.onChange = handler;
  }

  get borderColor(): ((str: string) => string) | undefined {
    return this.base.borderColor;
  }

  set borderColor(color: ((str: string) => string) | undefined) {
    this.base.borderColor = color;
  }

  // Proxy CustomEditor's app-level hooks. Pi uses these duck-typed properties
  // to wire actions such as Ctrl+G into a custom editor.
  get actionHandlers(): Map<unknown, () => void> | undefined {
    return (this.base as AppEditor).actionHandlers;
  }

  get onEscape(): (() => void) | undefined {
    return (this.base as AppEditor).onEscape;
  }

  set onEscape(handler: (() => void) | undefined) {
    (this.base as AppEditor).onEscape = handler;
  }

  get onCtrlD(): (() => void) | undefined {
    return (this.base as AppEditor).onCtrlD;
  }

  set onCtrlD(handler: (() => void) | undefined) {
    (this.base as AppEditor).onCtrlD = handler;
  }

  get onPasteImage(): (() => void) | undefined {
    return (this.base as AppEditor).onPasteImage;
  }

  set onPasteImage(handler: (() => void) | undefined) {
    (this.base as AppEditor).onPasteImage = handler;
  }

  get onExtensionShortcut(): ((data: string) => boolean) | undefined {
    return (this.base as AppEditor).onExtensionShortcut;
  }

  set onExtensionShortcut(handler: ((data: string) => boolean) | undefined) {
    (this.base as AppEditor).onExtensionShortcut = handler;
  }

  render(width: number): string[] {
    const lines = this.base.render(width);
    const pending = this.pendingOperator
      ? `${this.pendingOperator.count}${this.pendingOperator.operator}`
      : "";
    const label = ` ${this.mode.toUpperCase()}${pending}${this.count} `;
    if (lines.length > 0 && visibleWidth(lines[0]!) >= label.length) {
      const statusBackground = lines[0]!.match(/\x1b\[(?:\d+;)*48(?:;\d+)*m/)?.[0] ?? "";
      lines[0] = truncateToWidth(lines[0]!, width - label.length, "")
        + statusBackground + label + (statusBackground ? "\x1b[49m" : "");
    }
    return lines;
  }

  invalidate(): void {
    this.base.invalidate();
  }

  getText(): string {
    return this.base.getText();
  }

  setText(text: string): void {
    this.base.setText(text);
  }

  addToHistory(text: string): void {
    this.base.addToHistory?.(text);
  }

  insertTextAtCursor(text: string): void {
    this.base.insertTextAtCursor?.(text);
  }

  getExpandedText(): string {
    return this.base.getExpandedText?.() ?? this.base.getText();
  }

  setAutocompleteProvider(provider: AutocompleteProvider): void {
    this.base.setAutocompleteProvider?.(provider);
  }

  setPaddingX(padding: number): void {
    this.base.setPaddingX?.(padding);
  }

  setAutocompleteMaxVisible(maxVisible: number): void {
    this.base.setAutocompleteMaxVisible?.(maxVisible);
  }

  private resetParser(): void {
    this.count = "";
    this.pendingOperator = undefined;
  }

  private takeCount(): number {
    const count = Number(this.count || "1");
    this.count = "";
    return count;
  }

  private repeat(count: number, action: () => void): void {
    for (let index = 0; index < count; index++) action();
  }

  private moveHorizontally(distance: number): void {
    const key = distance < 0 ? "\x1b[D" : "\x1b[C";
    this.repeat(Math.abs(distance), () => this.base.handleInput(key));
  }

  private moveToWordEnd(bigWord: boolean): void {
    const editor = this.base as CursorEditor;
    const cursor = editor.getCursor?.();
    const line = cursor && editor.getLines?.()[cursor.line];
    if (cursor === undefined || line === undefined) return;

    let index = cursor.col;
    while (index < line.length && isWhitespace(line[index]!)) index++;
    if (index === line.length) return;

    const wordCharacter = isWordCharacter(line[index]!);
    while (
      index < line.length
      && !isWhitespace(line[index]!)
      && (bigWord || isWordCharacter(line[index]!) === wordCharacter)
    ) {
      index++;
    }
    this.moveHorizontally(index - 1 - cursor.col);
  }

  private moveToBigWordStart(): void {
    const editor = this.base as CursorEditor;
    const cursor = editor.getCursor?.();
    const line = cursor && editor.getLines?.()[cursor.line];
    if (cursor === undefined || line === undefined) return;

    let index = cursor.col;
    while (index < line.length && !isWhitespace(line[index]!)) index++;
    while (index < line.length && isWhitespace(line[index]!)) index++;
    this.moveHorizontally(index - cursor.col);
  }

  private deleteLines(count: number): void {
    this.repeat(count, () => {
      this.base.handleInput("\x01");
      this.base.handleInput("\x0b");
      this.base.handleInput("\x04");
    });
  }

  private executeInsert(insert: Insert): void {
    switch (insert) {
      case "after":
        this.base.handleInput("\x1b[C");
        break;
      case "lineStart":
        this.base.handleInput("\x01");
        break;
      case "lineEnd":
        this.base.handleInput("\x05");
        break;
      case "below":
        this.base.handleInput("\x05");
        this.base.handleInput("\x0a");
        break;
      case "above":
        this.base.handleInput("\x01");
        this.base.handleInput("\x0a");
        this.base.handleInput("\x1b[A");
        break;
      case "cursor":
        break;
    }
    this.mode = "insert";
  }

  private executeMotion(motion: Motion, count: number): void {
    switch (motion) {
      case "left":
        this.repeat(count, () => this.base.handleInput("\x1b[D"));
        break;
      case "down":
        this.repeat(count, () => this.base.handleInput("\x1b[B"));
        break;
      case "up":
        this.repeat(count, () => this.base.handleInput("\x1b[A"));
        break;
      case "right":
        this.repeat(count, () => this.base.handleInput("\x1b[C"));
        break;
      case "wordBackward":
        this.repeat(count, () => this.base.handleInput("\x1bb"));
        break;
      case "wordForward":
        this.repeat(count, () => this.base.handleInput("\x1bf"));
        break;
      case "bigWordForward":
        this.repeat(count, () => this.moveToBigWordStart());
        break;
      case "wordEnd":
        this.repeat(count, () => this.moveToWordEnd(false));
        break;
      case "bigWordEnd":
        this.repeat(count, () => this.moveToWordEnd(true));
        break;
      case "lineStart":
        this.base.handleInput("\x01");
        break;
      case "lineEnd":
        this.base.handleInput("\x05");
        break;
    }
  }

  private executeDelete(motion: DeleteMotion, count: number): void {
    switch (motion) {
      case "line":
        this.deleteLines(count);
        break;
      case "lineStart":
        this.base.handleInput("\x15");
        break;
      case "lineEnd":
        this.base.handleInput("\x0b");
        break;
      case "wordBackward":
      case "bigWordBackward":
        this.repeat(count, () => this.base.handleInput("\x17"));
        break;
      case "wordForward":
      case "bigWordForward":
      case "wordEnd":
      case "bigWordEnd":
        this.repeat(count, () => this.base.handleInput("\x1bd"));
        break;
    }
  }

  private execute(command: Command, count: number): void {
    switch (command.kind) {
      case "insert":
        this.executeInsert(command.insert);
        break;
      case "motion":
        this.executeMotion(command.motion, count);
        break;
      case "deleteChar":
        this.repeat(count, () => this.base.handleInput("\x1b[3~"));
        break;
      case "delete":
        this.executeDelete(command.motion, count);
        break;
      case "operator":
        break;
    }
  }

  private handlePendingOperator(data: string): boolean {
    const pending = this.pendingOperator!;
    if (isCountDigit(data) || (data === "0" && this.count)) {
      this.count += data;
      this.tui.requestRender();
      return true;
    }
    const child = pending.node.children?.[data];

    this.pendingOperator = undefined;
    if (child?.command) {
      this.execute(child.command, pending.count * this.takeCount());
    } else if (data.length > 1 || data.charCodeAt(0) < 32) {
      this.base.handleInput(data);
    }
    this.tui.requestRender();
    return true;
  }

  handleInput(data: string): void {
    if (matchesKey(data, "escape")) {
      if (this.mode === "insert") {
        this.mode = "normal";
      } else if (this.pendingOperator || this.count) {
        this.resetParser();
      } else {
        this.base.handleInput(data);
        return;
      }
      this.tui.requestRender();
      return;
    }

    if (this.mode === "insert") {
      this.base.handleInput(data);
      return;
    }

    if (this.pendingOperator) {
      this.handlePendingOperator(data);
      return;
    }

    if (isCountDigit(data) || (data === "0" && this.count)) {
      this.count += data;
      this.tui.requestRender();
      return;
    }

    const node = NORMAL_COMMANDS.children?.[data];
    if (node?.command?.kind === "operator") {
      this.pendingOperator = {
        count: this.takeCount(),
        node,
        operator: node.command.operator,
      };
      this.tui.requestRender();
      return;
    }

    if (node?.command) {
      this.execute(node.command, this.takeCount());
      this.tui.requestRender();
      return;
    }

    this.takeCount();
    if (data.length === 1 && data.charCodeAt(0) >= 32) return;
    this.base.handleInput(data);
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    const previous = ctx.ui.getEditorComponent();
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      const base = previous?.(tui, theme, keybindings) ?? new CustomEditor(tui, theme, keybindings);
      return new VimEditor(tui, base);
    });
  });
}
