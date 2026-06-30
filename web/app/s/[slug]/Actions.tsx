"use client";

import { useState } from "react";
import { Check, Copy } from "lucide-react";

/** Copy-the-link button for the viewer. The other actions are plain links. */
export default function CopyLink({ url }: { url: string }) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 1600);
    } catch {
      // Clipboard blocked (insecure context / permissions) — no-op; the link
      // is visible in the address bar regardless.
    }
  }

  return (
    <button
      type="button"
      onClick={copy}
      aria-live="polite"
      className="btn-lift inline-flex items-center gap-2 rounded-lg border border-bg3 px-4 py-2 font-mono text-sm text-fg1 hover:border-fg3 hover:text-fg0"
    >
      {copied ? (
        <Check className="h-4 w-4 text-green" />
      ) : (
        <Copy className="h-4 w-4" />
      )}
      {copied ? "copied" : "copy link"}
    </button>
  );
}
