# Pi Remote

Experimental, ultra-minimal mobile control for the currently active Pi TUI session.

`/remote` starts a localhost-only web server, exposes it through the official ngrok Node SDK, and renders a single-use pairing QR code in Pi. Scanning the QR exchanges a short-lived secret for a secure browser session, which can stream and control the active Pi session.

## Requirements

- Pi 0.84 or newer
- Node.js 22 or newer
- An ngrok account; `/remote setup` can save its authtoken, and existing ngrok CLI configuration is reused automatically

## Commands

```text
/remote          Start remote access or rotate the single-use pairing QR
/remote setup    Open ngrok setup and save an authtoken locally
/remote status   Show the current URL and pairing status
/remote close    Stop ngrok and the local server
```

## Current UI scope

The light mobile UI uses a restrained, typography-led hierarchy and renders assistant content with Comark. It currently shows:

- user messages and Comark-rendered assistant Markdown;
- streaming Markdown with incomplete syntax auto-closed;
- immediate optimistic display of prompts sent from the browser;
- compact tool activity labels;
- one composer with send and abort controls.

It omits thinking, raw tool arguments/results, file browsing, model controls, and session switching. This keeps the mobile surface auditable while the transport and live-session behavior stabilize.

## Security model

- The local server binds only to `127.0.0.1` on a random port.
- ngrok terminates HTTPS but performs no end-user authentication.
- The QR contains a random 128-bit single-use secret in the URL fragment, which is not sent to ngrok with the initial request.
- Browser JavaScript exchanges the secret once for an `HttpOnly; Secure; SameSite=Strict` session cookie.
- Pairing expires after five minutes, is invalidated after one successful exchange, and failed attempts are rate-limited.
- Only the inert bootstrap document and one-time pairing exchange are public. Every other route requires the session cookie.
- Running `/remote` while active rotates the pairing secret while preserving already paired browser sessions.
- The browser receives no provider credentials or Pi auth files.
- `/remote close` and Pi session shutdown terminate the tunnel.

The plain ngrok URL is not a credential. The QR image is a credential until it is used or expires, so keep it private. Remote access can execute tools with the same permissions as the local Pi process.

`/remote setup` first displays instructions and waits for Enter. It then opens ngrok's **Your Authtoken** page. After signing in, copy the token and return to Pi, where a masked field accepts the paste. Choose **Save to ngrok config** to persist it with owner-only permissions, or **Use once** to keep it only for the current setup. The token is never added to the Pi conversation. `NGROK_AUTHTOKEN` remains supported and takes precedence.
