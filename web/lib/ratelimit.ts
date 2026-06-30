// Zero-infra in-memory rate limiter. Best-effort: state lives per function
// instance (Fluid Compute reuses instances, so it holds within a region/instance),
// not a global source of truth. It's a speed bump against spam — the hard bill
// backstop is Vercel Spend Management. For strict global limits, swap for Upstash
// Redis (free tier) or a Vercel WAF rate-limit rule.

type Stamps = number[];
const buckets = new Map<string, Stamps>();
const MAX_KEYS = 10_000; // bound memory

export interface Limit {
  limit: number;
  windowMs: number;
}

export interface RateResult {
  ok: boolean;
  retryAfterSec: number;
}

/** Sliding-window check across one or more windows; fails on the tightest. */
export function rateLimit(key: string, limits: Limit[]): RateResult {
  const now = Date.now();
  const maxWindow = Math.max(...limits.map((l) => l.windowMs));

  if (buckets.size > MAX_KEYS) buckets.clear(); // crude overflow guard

  const stamps = (buckets.get(key) ?? []).filter((t) => now - t < maxWindow);

  for (const { limit, windowMs } of limits) {
    const inWindow = stamps.filter((t) => now - t < windowMs);
    if (inWindow.length >= limit) {
      const oldest = Math.min(...inWindow);
      return { ok: false, retryAfterSec: Math.ceil((windowMs - (now - oldest)) / 1000) };
    }
  }

  stamps.push(now);
  buckets.set(key, stamps);
  return { ok: true, retryAfterSec: 0 };
}

/** Best-effort client IP from Vercel/edge headers. */
export function clientIp(req: Request): string {
  const xff = req.headers.get("x-forwarded-for");
  if (xff) return xff.split(",")[0].trim();
  return req.headers.get("x-real-ip") ?? "unknown";
}
