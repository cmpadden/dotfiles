import { createHtmlRenderer } from "@comark/html";

const render = createHtmlRenderer({
  registerDefaultPlugins: false,
  autoClose: true,
  linkify: true,
});

export async function renderMarkdown(markdown) {
  return render(String(markdown || ""));
}
