import test from "node:test";
import assert from "node:assert/strict";
import { parseRemoteArgs, snapshotMessages } from "../lib/core.mjs";

test("parses the small command surface", () => {
  assert.equal(parseRemoteArgs(""), "open");
  assert.equal(parseRemoteArgs("status"), "status");
  assert.equal(parseRemoteArgs("close"), "close");
  assert.equal(parseRemoteArgs("setup"), "setup");
  assert.throws(() => parseRemoteArgs("wat"), /Usage/);
});

test("snapshot keeps only conversational text", () => {
  const messages = snapshotMessages([
    { type: "message", message: { role: "user", content: "hello" } },
    { type: "message", message: { role: "toolResult", content: [{ type: "text", text: "secret output" }] } },
    { type: "message", message: { role: "assistant", content: [{ type: "text", text: "hi" }, { type: "thinking", thinking: "hidden" }] } }
  ]);
  assert.deepEqual(messages, [
    { role: "user", text: "hello", error: false },
    { role: "assistant", text: "hi", error: false }
  ]);
});
