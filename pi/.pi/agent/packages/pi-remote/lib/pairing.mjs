import { createHash, randomBytes, timingSafeEqual } from "node:crypto";

export const PAIRING_TTL_MS = 5 * 60 * 1000;
export const SESSION_TTL_SECONDS = 8 * 60 * 60;
export const SESSION_COOKIE = "pi_remote_session";

export function randomToken() {
  return randomBytes(32).toString("base64url");
}

export function tokenHash(token) {
  return createHash("sha256").update(String(token)).digest();
}

export function tokenMatches(token, expectedHash) {
  if (!expectedHash || typeof token !== "string") return false;
  const actual = tokenHash(token);
  return actual.length === expectedHash.length && timingSafeEqual(actual, expectedHash);
}

export function createPairing(now = Date.now()) {
  const secret = randomToken();
  return { secret, hash: tokenHash(secret), expiresAt: now + PAIRING_TTL_MS };
}

export function pairingUrl(publicUrl, secret) {
  const url = new URL(publicUrl);
  url.hash = new URLSearchParams({ pair: secret }).toString();
  return url.toString();
}

export function parseCookies(header = "") {
  const cookies = {};
  for (const part of String(header).split(";")) {
    const separator = part.indexOf("=");
    if (separator < 0) continue;
    const key = part.slice(0, separator).trim();
    const value = part.slice(separator + 1).trim();
    if (key) cookies[key] = value;
  }
  return cookies;
}

export function sessionCookie(token) {
  return `${SESSION_COOKIE}=${token}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=${SESSION_TTL_SECONDS}`;
}

export function clearSessionCookie() {
  return `${SESSION_COOKIE}=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0`;
}
