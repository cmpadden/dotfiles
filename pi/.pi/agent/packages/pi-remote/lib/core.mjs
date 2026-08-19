export function parseRemoteArgs(input = "") {
  const [action = "open", ...rest] = String(input).trim().split(/\s+/).filter(Boolean);
  if (!["open", "status", "close", "setup"].includes(action)) {
    throw new Error("Usage: /remote [open|status|close|setup]");
  }
  if (rest.length) throw new Error("Usage: /remote [open|status|close|setup]");
  return action;
}

export function messageText(message) {
  if (!message) return "";
  if (typeof message.content === "string") return message.content;
  if (!Array.isArray(message.content)) return "";
  return message.content
    .filter((part) => part?.type === "text")
    .map((part) => part.text || "")
    .join("");
}

export function snapshotMessages(entries) {
  return entries
    .filter((entry) => entry?.type === "message")
    .map((entry) => entry.message)
    .filter((message) => message?.role === "user" || message?.role === "assistant")
    .map((message) => ({
      role: message.role,
      text: messageText(message),
      error: message.role === "assistant" && message.stopReason === "error"
    }))
    .filter((message) => message.text);
}
