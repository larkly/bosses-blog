# Lantern

An editorial Hugo theme. Three home layouts, dark/light/auto, OKLCH accents,
typographic focus. Built around a leaf-bundle workflow with first-class cover
images, series, link posts, and a self-hosted services directory.

![Hugo ≥ 0.144](https://img.shields.io/badge/Hugo-%E2%89%A5%200.144-informational)
![Hugo extended](https://img.shields.io/badge/Hugo-extended-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

## Features

- **Three home layouts** — `column` (classic), `broadsheet` (newspaper), `index` (dense year-grouped ledger). Pick one in `hugo.toml`, override via env var.
- **Post kinds** — Essay · Note · Link · Technical. Drives the kicker label and list styling; link posts render the title as an external `→` with the host in the kicker.
- **Cover images** — 16:9 hero on single posts, thumbnail on the broadsheet lead. Per-post control over focus point, aspect ratio, and fit mode. Page-bundle images auto-downscaled via Hugo image processing.
- **Series** — Named sequences with an ordered navigator banner at the top of each part, plus a `/series/` cloud and per-series landing page.
- **Home placement flags** — `pinned` promotes to top; `hideOnHome` excludes from home *and* from prev/next nav.
- **Related posts** — Hand-curated "See also" block above prev/next.
- **GitHub-style blockquote alerts** — `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]` render as coloured callouts.
- **Services portal** — `layout: services` page with sectioned/flat cards, status badges, and logos.
- **Typography & theme** — CSS custom properties, OKLCH colour, three font pairings, `clamp()`-based responsive type, auto/light/dark toggle persisted in `localStorage`.
- **Single-post chrome** — Sticky ToC at ≥ 1100 px, meta rail (publish date, reading time, kind, copy-link), drop cap (opt-out), tag chips.
- **Archive, tags, categories, RSS, 404** — stock Hugo, wired in.

## Requirements

- **Hugo ≥ 0.144**, **extended** build. `hugo version` should show `+extended`.
- Goldmark (default renderer). No Node/PostCSS/SCSS pipeline required.

## Installation

### As a Git submodule (recommended for now)

```sh
git submodule add https://github.com/larkly/hugo-lantern.git themes/lantern
```

### As a Hugo module

```sh
hugo mod init github.com/larkly/hugo-lantern
hugo mod get github.com/larkly/hugo-lantern
```

Add to `hugo.toml`:

```toml
theme = "lantern"
```

### By copy

Clone this repo, drop the contents into `themes/lantern/` of your site.

## Site configuration

All keys live under `[params]`; every one is optional.

```toml
baseURL     = "https://example.com/"
title       = "My Blog"          # Brand in the top-left of every page
theme       = "lantern"
enableEmoji = true               # :round_pushpin: → 📍 in Markdown

[params]
  description  = "Tagline for the <meta> description and home header"
  author       = "Jane Doe"
  homeTitle    = "My Blog"       # Big hero title on /
  tagline      = ""              # Optional, appended to homeTitle (column layout)

  homeLayout   = "broadsheet"    # column | broadsheet | index
  postsOnHome  = 12              # column layout only

  fontPairing  = "fraunces"      # fraunces | garamond | playfair
  accentHue    = 30              # OKLCH hue 0–360
  accentChroma = 0.15            # OKLCH chroma
  accentLight  = 0.55            # OKLCH lightness 0–1
  readWidth    = 64              # reading column width in `ch`
  defaultTheme = "auto"          # auto | light | dark

  showRSS      = true

[params.colophon]
  bodyFont     = "Source Serif 4"
  displayFont  = "Fraunces"
  monoFont     = "JetBrains Mono"

[[menu.main]]
  name = "Writing"; url = "/"; weight = 10
[[menu.main]]
  name = "Archive"; url = "/posts/"; weight = 20
[[menu.main]]
  name = "Tags"; url = "/tags/"; weight = 30
[[menu.main]]
  name = "About"; url = "/about/"; weight = 40

[markup.goldmark.renderer]
  unsafe = true                  # required for GitHub-style alerts

[taxonomies]
  tag    = "tags"
  series = "series"
```

Any `[params]` key is overridable at build time via `HUGO_PARAMS_<KEY>`:

```sh
HUGO_PARAMS_HOMELAYOUT=index HUGO_PARAMS_ACCENTHUE=210 hugo
```

## Front matter

### Posts — `content/posts/...`

```yaml
title: "On leaving things unfinished"
date: 2026-04-12
postkind: Essay              # Essay | Note | Link | Technical
dek: "A sub-title."          # optional hero dek
toc: true                    # default true; false to suppress
tags: [craft, writing]

# Cover image ------------------------------------------------------------
cover: cover.jpg             # bundle-relative, /absolute, or https://…
coverAlt:     "A stack of notebooks"
coverCaption: "Field studies"
coverCredit:  "Photo by Someone"
coverFocus:   "50% 30%"      # object-position; defaults to "center"
coverAspect:  "auto"         # 16/9 (default) | 4/3 | 1/1 | auto
coverFit:     "contain"      # cover (default, crops) | contain (letterboxes)

# Link posts (postkind: Link) -------------------------------------------
link: "https://elsewhere.example.com/article"

# Home placement --------------------------------------------------------
pinned:     false            # true → promote to top (broadsheet feature)
hideOnHome: false            # true → hide from home AND from prev/next

# Typography ------------------------------------------------------------
dropcap: true                # false → suppress the oversized first letter

# Series ----------------------------------------------------------------
series:      ["Building a platform"]
seriesOrder: 2

# Curated cross-links ---------------------------------------------------
relatedPosts:
  - /posts/another-essay/
  - /posts/yet-another/
```

> Hugo ≥ 0.144 reserved `kind` as a front-matter keyword, so the theme uses
> **`postkind`** instead.

#### Cover image resolution

The shared [`partials/cover.html`](layouts/partials/cover.html) resolves `cover`
in this order:

1. Absolute URL or leading `/` → served as-is.
2. Otherwise, looked up via `.Resources.GetMatch` (leaf-bundle sibling).
3. Falls back to site-root `relURL` (e.g. a file under `static/`).

When the resolved resource is an image larger than `1600 × 1600` on either axis,
it's downscaled with `.Fit "1600x1600 q85"` at build time. The emitted `<img>`
carries intrinsic `width`/`height` (no layout shift) and the wrapper `<figure>`
caps at the image's native width (no upscaling past source resolution).

### Pages — `type: page`

Static pages like `/about/`:

```yaml
title: "About"
date: 2026-01-01
type: page
layout: single
avatar: /images/portrait.jpg
kicker: "Colophon & about"
```

Renders: optional kicker, H1, 1:2 grid of avatar + body.

### Services portal — `layout: services`

A directory-of-things page. See the "Services portal" section below.

## Home layouts

| Value        | Look                                                                          |
| ---          | ---                                                                           |
| `column`     | Centred reading column. Hero + flat list of `post-item`s.                     |
| `broadsheet` | Newspaper: cover-led feature, sidebar, three-column lower deck.               |
| `index`      | Dense, year-grouped ledger. Text-only. Good for high post counts.             |

All three honour `pinned` (promote to top) and `hideOnHome` (exclude entirely),
implemented centrally by [`partials/home-posts.html`](layouts/partials/home-posts.html).

## Series

Posts that share a `series` string form an ordered sequence:

```yaml
series:      ["Building a platform"]
seriesOrder: 2
```

Rendered as a "Series · Part 2 of 5" box at the top of every post in the series,
with a numbered list of parts and a `← you are here` marker on the current one.
Because `series` is a standard Hugo taxonomy, you also get:

- `/series/` — a cloud of all series, weighted by post count.
- `/series/<slug>/` — parts listed in `seriesOrder` ascending.

A post can belong to multiple series by listing several strings; the banner
shows only the first.

## Link posts

Set `postkind: Link` and provide a `link:` URL. The home/list item becomes a
click-through to the external URL (new tab), with the source host in the
kicker. The single page adds:

- "About an article at …" attribution under the meta row,
- "Read more at …" pill above the tags,
- `<link rel="canonical">` pointing at the external URL.

## Prev / next navigation

The bottom nav on single posts walks the section in Hugo's default order
(newest first) and skips any post with `hideOnHome: true`. If the current post
is itself hidden, no nav block is rendered.

## GitHub-style alerts

With `markup.goldmark.renderer.unsafe = true`, blockquotes whose first line is
`[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, or `[!CAUTION]` render as
coloured callouts. The render hook lives at
[`_default/_markup/render-blockquote.html`](layouts/_default/_markup/render-blockquote.html).

```markdown
> [!WARNING]
> This operation is destructive.
```

## Services portal

Ship a `content/services.md` page:

```yaml
---
title: "Services"
kicker: "What I run"
layout: services
description: "A small directory."
sections:
  - title: "Code & writing"
    note:  "Where text gets drafted."
    services:
      - name: "GitLab"
        url:  "https://gitlab.example.com"
        desc: "My git forge."
        image: /images/logos/gitlab.png
        status: online          # online | maintenance | offline
        statusLabel: "Online"   # optional override
---
```

A flat `services:` list at the top level (without `sections`) also works.

Per-card fields:

| Key           | Required | Notes                                                               |
| ---           | ---      | ---                                                                 |
| `name`        | ✓        | Card title.                                                         |
| `url`         | ✓        | Target URL. Host is extracted for the card footer.                  |
| `desc`        |          | Markdown-rendered.                                                  |
| `image`       |          | Logo; if omitted, a hatched `[ name ]` placeholder is shown.        |
| `status`      |          | `online` (default) · `maintenance` · `offline` — drives a coloured dot. |
| `statusLabel` |          | Override the dot's text.                                            |

Logos go under `static/images/logos/`.

## Overriding styles

The theme ships `static/css/styles.css`. To customise without forking, copy
specific rules into your site's `static/css/site.css` and reference it from
`baseof.html` override — or drop a same-path file in your site's `static/` to
shadow the theme's copy wholesale.

Key CSS custom properties live in `:root` at the top of `styles.css`:
`--accent-hue`, `--accent-chroma`, `--accent-light`, `--read-width`,
`--paper-*`, `--ink-*`, `--rule-*`.

## Directory layout

```
themes/lantern/
├── theme.toml
├── config.example.toml
├── README.md            # this file
├── LICENSE
└── layouts/
    ├── 404.html
    ├── index.html                          # home — routes to column|broadsheet|index
    ├── _default/
    │   ├── baseof.html                     # base shell, <head>, theme bootstrap
    │   ├── list.html                       # year-grouped archive / tag list
    │   ├── single.html                     # single post (ToC + rail + cover)
    │   ├── services.html                   # services portal
    │   ├── terms.html                      # tag / series cloud
    │   └── _markup/
    │       └── render-blockquote.html      # GitHub-style alerts
    ├── page/single.html                    # static pages (about, colophon…)
    ├── taxonomy/
    │   └── series.html                     # per-series landing (ordered by seriesOrder)
    └── partials/
        ├── header.html
        ├── footer.html
        ├── post-item.html                  # row on column home / lists
        ├── home-posts.html                 # pinned + hideOnHome central logic
        ├── cover.html                      # shared cover rendering
        ├── series-box.html                 # per-post series navigator
        ├── related-posts.html              # "See also" block
        ├── service-card.html               # one services-portal tile
        └── home/
            ├── column.html
            ├── broadsheet.html
            └── index.html
```

## Development

```sh
hugo server           # live reload at http://localhost:1313
hugo                  # production build into public/
```

Templates stick to stock Hugo functions (`.Resources.GetMatch`,
`.GroupByDate`, `.Pages`, `.Scratch`, `where`, `cond`, `delimit`, `urls.Parse`,
`markdownify`, `safeHTML`, `safeCSS`, `safeHTMLAttr`, `replaceRE`). No
node_modules, no external build step.

## License

MIT — see [LICENSE](LICENSE).
