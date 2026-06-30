import { NextResponse } from "next/server";
import { lookup, normalizeKey } from "@/lib/license";

// Serverless license check (plan §25/§48). Fail-open is the CLIENT's job:
// if this endpoint is unreachable, the app grants a grace period and keeps
// working. This route just validates a key's shape/registry. Key format and
// lookup live in lib/license.ts (shared with the hosted-upload route).
export const dynamic = "force-dynamic";

export async function POST(req: Request) {
  let key = "";
  try {
    const body = await req.json();
    key = normalizeKey(body?.key);
  } catch {
    return NextResponse.json(
      { valid: false, error: "Invalid JSON body" },
      { status: 400 },
    );
  }

  if (!key) {
    return NextResponse.json(
      { valid: false, error: "Missing 'key'" },
      { status: 400 },
    );
  }

  const result = lookup(key);
  return NextResponse.json(
    { valid: result.valid, plan: result.plan },
    { status: result.valid ? 200 : 402 },
  );
}
