# Product

## Register

brand

## Users

Developers and technical power-users on macOS (13+, Apple Silicon & Intel) who
take and share screenshots constantly — in PRs, issues, Slack, docs. They live
in the terminal and editor, value speed and keyboard-driven flow, and are
skeptical of bloated, account-walled "productivity" tools. They arrive at the
site to evaluate a utility in under a minute and decide whether to download.

## Product Purpose

Nab is a macOS menubar capture tool that drops a clean shareable link onto the
clipboard the instant you capture. It works hosted out of the box (nothing to
set up) or self-hosted against the user's own R2 / S3 bucket. The site's job:
communicate the core promise (capture → link on clipboard, instantly), establish
developer-tool credibility, and drive the macOS download. Success = a visitor
understands the value in one screen and clicks Download.

## Brand Personality

Terminal-native, fast, exact, quietly confident. Voice borrows from the
developer's own environment — a shell prompt (`~/nab`), a vim modeline, a
blinking block caret — without becoming a costume. Three words: **sharp,
unfussy, credible.** It should feel like a tool a senior engineer built for
themselves, not a product marketed at them.

## Anti-references

- **Generic SaaS template**: no gradient-hero + feature-card-grid + hero-metric
  scaffold; no Stripe/Linear-clone landing. The terminal voice must do real
  work, not sit on top of a stock template.
- **Corporate / enterprise**: no navy-and-gray palette, no stock imagery, no
  buttoned-up "trusted by" enterprise tone.
- Also avoid: over-animated/parallax gimmickry and toy/cute playfulness — keep
  the credibility of a real developer tool.

## Design Principles

1. **Show the product working.** The capture-to-clipboard motion is the pitch;
   demonstrate it, don't just describe it.
2. **Speak the user's environment.** Terminal/TUI cues (prompt, modeline, mono
   type) are the brand voice — used deliberately, never as decoration.
3. **Earn every effect.** Motion and visual flourish must clarify or delight a
   real moment; remove anything that's reflex.
4. **One screen to value.** A visitor should grasp the promise and find the
   download without scrolling hunting.
5. **Restraint over noise.** Committed dark gruvbox palette with orange doing
   the pointing; quiet structure (grid, glow) under loud-enough type.

## Accessibility & Inclusion

Target **WCAG 2.1 AA**: body text ≥4.5:1 against its background (watch muted
`--color-gray` on the dark bg), large text ≥3:1, visible on-brand focus rings
(already present), full keyboard navigation. Every animation must have a
`prefers-reduced-motion: reduce` alternative (crossfade or instant) — already
scaffolded in globals.css; keep it complete as new motion is added.
