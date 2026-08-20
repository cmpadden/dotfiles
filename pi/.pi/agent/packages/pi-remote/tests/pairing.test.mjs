import test from "node:test";
import assert from "node:assert/strict";
import {
  SESSION_COOKIE,
  createPairing,
  pairingUrl,
  parseCookies,
  sessionCookie,
  tokenMatches,
} from "../lib/pair-auth.mjs";

test("pairing secrets are strong, hashed, and expire", () => {
  const pairing = createPairing(1000);
  assert.equal(pairing.secret.length, 22);
  assert.equal(pairing.hash.length, 32);
  assert.ok(pairing.expiresAt > 1000);
  assert.equal(tokenMatches(pairing.secret, pairing.hash), true);
  assert.equal(tokenMatches("wrong", pairing.hash), false);
});

test("accepts current and legacy pairing fragments", () => {
  const pairing = createPairing();
  assert.equal(tokenMatches(pairing.secret, pairing.hash), true);
  assert.equal(tokenMatches(`pair=${pairing.secret}`, pairing.hash), true);
  assert.equal(tokenMatches(`#pair=${pairing.secret}`, pairing.hash), true);
});

test("pairing secret stays in the URL fragment", () => {
  const url = pairingUrl("https://example.ngrok-free.app", "secret-value");
  const parsed = new URL(url);
  assert.equal(parsed.search, "");
  assert.equal(parsed.hash.slice(1), "secret-value");
});

test("session cookie is hardened", () => {
  const cookie = sessionCookie("session-token");
  assert.match(cookie, new RegExp(`^${SESSION_COOKIE}=`));
  assert.match(cookie, /HttpOnly/);
  assert.match(cookie, /Secure/);
  assert.match(cookie, /SameSite=Strict/);
  assert.equal(parseCookies(`${cookie}; other=value`)[SESSION_COOKIE], "session-token");
});
