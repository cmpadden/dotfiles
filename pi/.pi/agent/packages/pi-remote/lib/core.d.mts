export function parseRemoteArgs(input?: string): "open" | "status" | "close" | "setup";
export function messageText(message: unknown): string;
export function snapshotMessages(entries: readonly unknown[]): Array<{ role: "user" | "assistant"; text: string; error: boolean }>;
