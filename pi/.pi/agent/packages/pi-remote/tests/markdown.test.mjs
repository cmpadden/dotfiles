import test from "node:test";
import assert from "node:assert/strict";
import { renderMarkdown } from "../lib/markdown.mjs";

test("renders CommonMark and GFM content", async () => {
  const html = await renderMarkdown("# Result\n\n- **one**\n- `two`\n\n| A | B |\n| - | - |\n| 1 | 2 |");
  assert.match(html, /<h1/);
  assert.match(html, /<strong>one<\/strong>/);
  assert.match(html, /<code>two<\/code>/);
  assert.match(html, /<table>/);
});

test("auto-closes streaming markdown", async () => {
  assert.match(await renderMarkdown("A **partial"), /<strong>partial<\/strong>/);
});

test("escapes embedded HTML", async () => {
  const html = await renderMarkdown('<script>alert(1)</script>\n\n<img src=x onerror="alert(2)">');
  assert.doesNotMatch(html, /<script>|<img/);
  assert.match(html, /&lt;script&gt;/);
  assert.match(html, /&lt;img/);
});
