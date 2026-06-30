# Design System: Nab

> Codifies the **shipped** visual system (Next.js 15 + Tailwind v4, `app/globals.css`).
> Register: **brand** (see [PRODUCT.md](PRODUCT.md)). This is a terminal-native developer
> tool, so a few of the generic "premium" defaults are deliberately overridden —
> those divergences are called out inline as **[Nab divergence]**.

## 1. Visual Theme & Atmosphere

A dim, warm, terminal-native surface — Gruvbox-dark rendered as a product, not a
costume. The mood is **sharp, unfussy, credible**: a tool a senior engineer built for
themselves. Light cream text floats on layered warm-charcoal panels under a single
faint orange bloom anchored behind the hero, with a whisper-faint dot grid for quiet
structure. One brand color (orange) does all the pointing; everything else recedes.

- **Density:** Daily-App Balanced (≈4). Generous hero whitespace, compact mono UI chrome.
- **Variance:** Offset-Asymmetric (≈5). The hero is an intentional asymmetric two-column
  split (`1.05fr / 1fr`), never centered. Body stays calm and aligned.
- **Motion:** Fluid CSS (≈6). Purposeful entrance choreography + two restrained infinite
  loops (caret blink, clipboard shimmer). Never cinematic, never bouncy.

## 2. Color Palette & Roles

Uniformly **warm** (Gruvbox). The ramp never fluctuates between warm and cool grays —
the warmth is the identity. **[Nab divergence]** from the generic "absolute neutral
Zinc/Slate" rule: that would erase the brand.

**Surfaces (dark → light, layered depth)**
- **Hard Charcoal** (`#1d2021`) — deepest surface: window chrome, footer, recessed cards (`--bg0-hard`)
- **Base Charcoal** (`#282828`) — page background (`--bg0`)
- **Panel 1 / 2 / 3** (`#3c3836` / `#504945` / `#665c54`) — borders, raised chips, hairlines (`--bg1/2/3`)
- Body backdrop is **not a flat fill**: a fixed composited layer carries a faint orange
  radial bloom + a vertical tonal shift (`#2c2b28 → #282828 → #232220`) + a 22px dot
  texture. Never pure black (`#000000`).

**Ink (light cream on dark — add ~0.05–0.1 line-height vs. dark-on-light)**
- **Bright Cream** (`#fbf1c7`) — primary headings, emphasis (`--fg0`)
- **Cream** (`#ebdbb2`) — body copy (`--fg1`)
- **Dim Cream** (`#bdae93`) — secondary copy, muted paragraphs (`--fg3`)
- **Warm Gray** (`#a89984`) — metadata, footer links, fine print (`--gray`). Verified
  ≥4.5:1 on every surface (WCAG AA). Do **not** revert to `#928374` — it fails AA as body text.

**Accent — the single brand color**
- **Signal Orange** (`#fe8019`) — primary CTAs, the `~/` prompt, caret, focus ring, active states (`--orange`)
- **Ember** (`#d65d0e`) — orange's darker shoulder, used only inside the clipboard shimmer (`--orange-dim`)
- **Amber** (`#fabd2f`) — primary-button hover target only (`--yellow`)

**Semantic (product-mock + docs only, never decorative)**
- **Lime** (`#b8bb26`) success · **Aqua** (`#8ec07c`) info · **Red** (`#fb4934`) error/destructive.
  These exist to read as a real macOS app (traffic-light dots, status). Not part of the marketing palette.

**Banned:** AI purple/blue neon glows, oversaturated accents, cool slate grays mixed into
the warm ramp, pure black.

## 3. Typography Rules

Two families, paired on a clear contrast axis (geometric mono vs. neutral grotesque) —
not two similar sans. **The mono carries the brand voice; the sans is the quiet workhorse.**

- **Display & Voice — JetBrains Mono** (`--font-mono`): the `~/nab` prompt, the vim
  modeline, kbd caps, eyebrow labels, dimension badges, the demo URL, docs step titles.
  This is what makes Nab read as terminal-native. Track-tight, weight-driven.
- **Body — Inter** (`--font-sans`): hero subcopy, paragraphs, button text. Relaxed leading
  (`leading-relaxed`), capped ≤65–75ch (`max-w-md` hero, `max-w-2xl` docs prose).
  **[Nab divergence]** the generic ban on Inter is *waived here by design choice*: the mono
  is the expressive face, so Inter intentionally stays neutral and out of the way. Documented,
  not accidental.
- **Scale:** headings via `clamp()`. Hero `clamp(2.5rem, 6vw, 4rem)` (max ≤6rem), `leading-1.05`,
  `tracking-tight` (≥ −0.04em floor respected). `text-wrap: balance` on h1–h3, `pretty` on prose.
- **Selection/Focus:** orange selection (`::selection` → orange on hard-charcoal); focus ring
  is 2px solid orange, 2px offset.

**Banned:** serif faces anywhere (this is a software brand), all-caps body copy, headings
above 6rem, letter-spacing tighter than −0.04em, emoji in UI copy.

## 4. Component Stylings

- **Buttons.** Primary = solid Signal Orange, ink text (`text-bg0-hard`), hover → Amber.
  Shared `btn-lift` raises `translateY(-2px)` on hover; `btn-glow` adds a soft orange shadow
  + a single light-sweep shine. Secondary = ghost with `border-bg3`, hover brightens border +
  ink. **No outer neon glow, no custom cursor.** (Add `active:translate-y-0` for tactile press
  if extending.)
- **Containers / "windows".** `rounded-xl`/`rounded-2xl`, `border-bg2`, `bg-bg0-hard`,
  `shadow-2xl shadow-black/40`. The product mock and docs terminals use a macOS window-chrome
  header (red/amber/lime traffic-light dots + a mono title). Cards are used only when a panel
  genuinely is a window/surface — **no repeated icon+heading+text card grid.**
- **Kbd caps.** Bordered (`border-bg3`), `bg-bg1`, mono, with an inset bottom shadow
  (`shadow-[0_2px_0_0_--bg0-hard]`) so they read as physical keys. Gesture hint reads
  `double-tap ⌘` (the real trigger), never two bare `⌘` keys.
- **Chips / badges.** Pill, `border-bg2`, hard-charcoal fill, mono micro-text, often a tiny
  status dot (e.g. lime "macOS menubar utility").
- **Footer = vim modeline.** Orange `NORMAL` block + version + mono links. A deliberate,
  named brand element — not a generic footer.
- **Loaders / empty / error (when added):** skeletal blocks matching layout dimensions (no
  circular spinners); empty states composed with the terminal voice; errors inline using Red,
  with a recovery path.

## 5. Layout Principles

- **Containment:** `max-w-5xl` (~1024px) for the landing, `max-w-4xl` docs, `max-w-3xl` CTA;
  `px-6` gutters (`px-5` docs). Centered column, asymmetric content.
- **Hero is asymmetric and never centered:** `lg:grid-cols-[1.05fr_1fr]`, copy left, live
  product mock right.
- **Grid for 2D, flex for 1D.** No `calc()` percentage hacks. Responsive grids that need it use
  `repeat(auto-fit, minmax(280px, 1fr))`.
- **Rhythm:** vary spacing deliberately — generous hero/section padding (`pt-20`–`pt-28`,
  `pb-28`), tight mono UI clusters. No uniform reflexive padding.
- **One screen to value:** the landing earns the download in the first fold; resist bolting on
  SaaS feature-grid sections (an explicit anti-reference).
- **Full-height sections** use `min-h-dvh`, never `h-screen`.
- **No overlapping content stacks** beyond the intentional layered window/badge depth.

## 6. Motion & Interaction

Purposeful, exponential ease-out, no bounce/elastic. Hardware-accelerated only.

- **Signature easings:** `cubic-bezier(0.16, 1, 0.3, 1)` (rise/reveal, underline draw) and
  `cubic-bezier(0.22, 1, 0.36, 1)` (marquee glide, success pop). Buttons 0.2s; entrances 0.6–0.7s.
- **Entrance choreography:** `animate-rise` (fade + 14px lift) on hero, staggered via
  `animation-delay`; `Reveal` lifts sections in on `IntersectionObserver` (not scroll listeners).
- **The product mock** demonstrates the core promise (drag → marquee → flash → "copied",
  cycling aspect ratios). It is **gated to run only while on-screen and the tab is visible** —
  no idle CPU/battery cost.
- **Two deliberate infinite loops, total:** caret `blink` (1.1s step-end) and the `clipboard`
  shimmer (3.6s linear). **[Nab divergence]** the shimmer is animated gradient text on a single
  signature word — normally a banned pattern; here it is the one sanctioned exception, with a
  solid-orange `prefers-reduced-motion` fallback. Do not introduce more gradient text.
- **Animate `transform`/`opacity`/`background-position` only.** The mock's small bounded
  marquee is the sole width/height transition and stays bounded.
- **Reduced motion is complete:** every animation has a `prefers-reduced-motion: reduce`
  fallback (crossfade/instant); the mock jumps straight to its captured state. Keep this
  invariant as motion is added.

## 7. Anti-Patterns (Banned)

- No glassmorphism as decoration — `backdrop-blur` only on the sticky nav/headers.
- No eyebrow kicker above every section; no `01 / 02 / 03` numbered markers except a genuine
  sequence (the docs setup steps qualify).
- No generic 3-up icon+heading+text feature-card grid; no nested cards.
- No side-stripe `border-left` accents.
- No additional gradient text beyond the single shimmer word; no gradient-filled headings.
- No generic SaaS template or corporate navy/gray (the brand anti-references).
- No monospace-as-costume drift: mono is the *voice*, applied to terminal/keyboard/metadata
  contexts, not sprinkled decoratively.
- No emoji in UI copy; no AI copywriting clichés ("Elevate", "Seamless", "Unleash", "Next-Gen");
  no fake round metrics; no placeholder names (`you.dev`, "Acme").
- No pure black, no neon/outer-glow shadows, no custom cursors, no `h-screen`.
- Body text must clear WCAG AA (≥4.5:1) — never muted gray that fails contrast.
