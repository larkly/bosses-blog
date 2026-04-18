---
title: "Working with OKLCH in practice"
date: 2026-02-17
postkind: Technical
dek: "A designer's notes on what OKLCH actually buys you in production CSS."
toc: true
tags: [css, color, design-systems]
categories: [Technical]
---

OKLCH has been around long enough that the novelty has worn off, and we can talk
about it as a tool rather than an idea. After a year of using it as the primary color
model in a mid-sized design system, here's what I've learned.

## The shape of the space

OKLCH is a cylindrical transformation of OKLab: lightness, chroma, and hue. Unlike HSL,
the lightness component actually corresponds to how bright a color *looks*. This sounds
small but it changes how you write code.

```css
:root {
  --accent: oklch(0.55 0.15 30);
  --accent-soft: oklch(0.55 0.15 30 / 0.12);
}

[data-theme="dark"] {
  --accent: oklch(0.72 0.12 30);
}
```

Compare that to the HSL version of the same pattern, where you'd spend ten minutes
fighting the fact that `hsl(15 55% 55%)` and `hsl(15 55% 72%)` don't feel like the
same hue shifted.

## Accessibility testing gets easier

Contrast ratios in APCA and WCAG 3 draft correlate reasonably well with OKLCH's L
axis. That doesn't mean you can skip the math — you still need to check — but it
means your color swatches will behave when you ramp them, which is not true of HSL.

A concrete example: a nine-step ramp from `oklch(0.15 ... 30)` to `oklch(0.95 ... 30)`
in equal L increments produces swatches that look evenly spaced. The same exercise in
HSL produces a ramp where the middle three swatches collapse visually.

## The catches

1. **Chroma is not independent of lightness.** High-chroma colors at extreme lightness
   values silently clamp. You'll get warnings in devtools but no visible change.
2. **Display P3 vs sRGB.** OKLCH can describe colors outside the sRGB gamut. Safari
   displays them on P3 screens; other browsers clip. Test on the device you're
   designing for.
3. **Legacy tooling doesn't speak it.** If you export design tokens to a platform
   (iOS, Android, anything that consumes JSON and produces hex), you need a conversion
   step. I use `culori` for this.

## What I'd do differently

Start with OKLCH as your authoring format. Ship sRGB fallbacks through PostCSS. Don't
try to retrofit an existing HSL system — the rampings won't be the same and you'll
chase ghosts for a month.
