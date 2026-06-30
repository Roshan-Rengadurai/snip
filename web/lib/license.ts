// Shared license validation. Used by both the license-verify endpoint and the
// hosted-upload token route, so the key format lives in exactly one place.
//
// v0 stub: accepts keys matching NB-XXXX-XXXX-XXXX (base32-ish). Swap `lookup`
// for a real store (KV / D1 / DB) later. No PII beyond the key.

export const KEY_RE = /^NB-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$/;

export interface LicenseResult {
  valid: boolean;
  plan: string;
}

/** Normalize a raw key into the canonical NB-XXXX-XXXX-XXXX shape. */
export function normalizeKey(raw: unknown): string {
  return typeof raw === "string" ? raw.trim().toUpperCase() : "";
}

/** Placeholder registry. Replace with a real lookup. */
export function lookup(key: string): LicenseResult {
  if (KEY_RE.test(key)) return { valid: true, plan: "personal" };
  return { valid: false, plan: "none" };
}
