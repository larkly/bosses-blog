# Lantern — Hugo Blog Theme

A simple, editorial Hugo blog theme. Three home layouts, dark/light, dense archive, tag cloud, 404. Hand-set in serifs.

## Files

```
hugo/
├── config.toml                       # site config + theme params
├── layouts/
│   ├── 404.html
│   ├── _default/
│   │   ├── baseof.html               # base shell, head, theme bootstrap
│   │   ├── list.html                 # section / archive listing (year-grouped)
│   │   ├── single.html               # post (with optional ToC + meta rail)
│   │   └── terms.html                # tag cloud
│   ├── index.html                    # home — picks one of the three home partials
│   ├── page/single.html              # static pages (about, colophon, etc.)
│   └── partials/
│       ├── header.html
│       ├── footer.html
│       ├── post-item.html
│       └── home/
│           ├── column.html           # V1 — classic centered column
│           ├── broadsheet.html       # V2 — newspaper / asymmetric
│           └── index.html            # V3 — dense year-grouped index
└── static/
    ├── css/styles.css                # the entire stylesheet (copy from mockup)
    └── js/app.js                     # theme toggle, copy-link, TOC scroll-spy
```

## Setup

1. Install Hugo (extended).
2. Place these files inside `themes/lantern/` of your site, or run as a standalone site by putting them at the project root.
3. Copy `styles.css` from the project root into `hugo/static/css/styles.css`.
4. `hugo server` — done.

## Configuration (config.toml)

Tweak any of these in `[params]`:

| Key | Values | Purpose |
|---|---|---|
| `homeLayout` | `column` · `broadsheet` · `index` | Which of the three home designs to use |
| `fontPairing` | `fraunces` · `garamond` · `playfair` | Font pairing |
| `accentHue` | 0–360 | OKLCH hue for the accent color |
| `accentChroma` / `accentLight` | numbers | OKLCH chroma + lightness |
| `readWidth` | ch (e.g. 64) | Reading column width |
| `defaultTheme` | `auto` · `light` · `dark` | Default theme (user can override) |
| `postsOnHome` | int | How many posts to show on the home column layout |

## Front matter

Posts (`content/posts/my-post.md`) support these params:

```yaml
title: "On the discipline of leaving things unfinished"
date: 2026-04-12
kind: Essay         # Essay | Note | Link | Technical — drives the kicker + index pill
dek: "A year-long argument with myself about drafts."   # optional sub-title
toc: true           # default true; set false to suppress on long posts
tags: [craft, writing, drafts]
categories: [Craft]
```

## Pages

- `/` → home (one of three layouts)
- `/posts/...` → single posts under section `posts`
- `/archive/` → year-grouped listing (uses `layouts/_default/list.html`)
- `/tags/` → tag cloud
- `/tags/<tag>/` → list view, year-grouped
- `/about/` → page (markdown content + optional `avatar` param)
- 404

## Notes

- Dark mode is auto by default, with a header toggle that cycles `auto → light → dark`. Persisted in localStorage.
- The single-post template renders a sticky table of contents on the left and a meta rail on the right at ≥1100px; both collapse cleanly on mobile.
- All typography uses `clamp()` for responsive scaling — no media-query font swaps needed.
