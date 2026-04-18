# hugo-newblog-design

An example Hugo site that ships with the **Lantern** theme — an editorial blog
design originating from Claude Design (`simple-hugo-blog`). Three home layouts,
dark / light / auto mode, OKLCH accents, optional cover images, a typed
services portal, and a typographic focus.

- [hugo-newblog-design](#hugo-newblog-design)
  - [What's in the box](#whats-in-the-box)
  - [Running](#running)
  - [Site config (`hugo.toml`)](#site-config-hugotoml)
    - [The brand vs. the home hero](#the-brand-vs-the-home-hero)
    - [Override any param at build time](#override-any-param-at-build-time)
    - [Menu](#menu)
  - [Home layouts](#home-layouts)
  - [Posts](#posts)
    - [What each `postkind` changes](#what-each-postkind-changes)
    - [Page bundles work fine](#page-bundles-work-fine)
    - [Single-post features](#single-post-features)
  - [Pages (`type: page`)](#pages-type-page)
  - [Services portal (`layout: services`)](#services-portal-layout-services)
    - [Fields per service](#fields-per-service)
    - [Logos](#logos)
  - [Taxonomies, archive, RSS, 404](#taxonomies-archive-rss-404)
  - [Static assets \& images](#static-assets--images)
  - [Icons in Markdown](#icons-in-markdown)
  - [Hugo compatibility](#hugo-compatibility)
  - [License](#license)

## What's in the box

```
.
├── hugo.toml                   # Site config (baseURL, params, menu)
├── content/
│   ├── about.md                # About / colophon (type: page, layout: single)
│   ├── services.md             # Services portal (layout: services)
│   └── posts/                  # Blog posts (Essay · Note · Link · Technical)
├── static/
│   ├── images/                 # Site-level static images (portraits, covers…)
│   └── images/logos/           # Service-card logos (see its own README)
└── themes/lantern/
    ├── theme.toml              # Theme metadata
    ├── config.example.toml     # Example site config (reference only)
    ├── README.md               # Legacy theme notes
    └── layouts/
        ├── 404.html
        ├── index.html                          # home — picks a home layout
        ├── _default/
        │   ├── baseof.html                     # base shell, <head>, theme bootstrap
        │   ├── list.html                       # section / archive (year-grouped)
        │   ├── single.html                     # post (ToC + meta rail + hero)
        │   ├── services.html                   # services portal
        │   └── terms.html                      # tag cloud
        ├── page/single.html                    # static pages (about, colophon…)
        └── partials/
            ├── header.html
            ├── footer.html
            ├── post-item.html                  # row on the column home / lists
            ├── service-card.html               # one service tile
            └── home/
                ├── column.html                 # V1 — centred reading column
                ├── broadsheet.html             # V2 — asymmetric newspaper (cover-aware)
                └── index.html                  # V3 — dense year-grouped index
    └── static/
        ├── css/styles.css                      # entire stylesheet
        └── js/app.js                           # theme toggle + copy-link + ToC spy
```

## Running

Prereq: **Hugo 0.144 or newer, extended build** (`hugo version` should show
`+extended`).

```
hugo server     # live reload at http://localhost:1313
hugo            # production build into public/
```

If static assets 404 or styling looks stale, your `hugo server` process is
probably holding a stale watcher — stop it and re-run.

## Site config (`hugo.toml`)

Everything the site author tweaks lives in `[params]`. All keys are optional
unless noted; sensible defaults live in the theme.

```toml
baseURL      = "https://example.com/"
title        = "Bosse writes"          # Used as the top-left brand
theme        = "lantern"
enableEmoji  = true                    # lets you write :round_pushpin: → 📍 in markdown

[params]
  description   = "Yak shaving as a service"     # tagline under the title / meta desc
  author        = "Bosse Klykken"
  homeTitle     = "The Yak Shaver"               # shown on the home hero (column + broadsheet)
  tagline       = ""                             # optional, appended after homeTitle (column only)

  # Home layout selector
  homeLayout    = "broadsheet"                   # column | broadsheet | index
  postsOnHome   = 12                             # used by the column layout

  # Typography / colour
  fontPairing   = "fraunces"                     # fraunces | garamond | playfair
  accentHue     = 30                             # OKLCH hue 0–360
  accentChroma  = 0.15                           # OKLCH chroma (saturation)
  accentLight   = 0.55                           # OKLCH lightness 0–1
  readWidth     = 64                             # reading column width, in ch

  # Theme (dark / light)
  defaultTheme  = "auto"                         # auto | light | dark — user can override via ◐

  # Misc
  showRSS       = true                           # RSS link in the header nav

[params.colophon]   # shown in the footer
  bodyFont    = "Source Serif 4"
  displayFont = "Fraunces"
  monoFont    = "JetBrains Mono"
```

### The brand vs. the home hero

- `title`    → the top-left brand in every page header.
- `homeTitle` → the big hero title on the front page (`column` and `broadsheet`).

If `homeTitle` is unset, the hero falls back to `title`.

### Override any param at build time

All `[params]` map to `HUGO_PARAMS_*` env vars:

```
HUGO_PARAMS_HOMELAYOUT=broadsheet hugo server
HUGO_PARAMS_FONTPAIRING=playfair HUGO_PARAMS_ACCENTHUE=210 hugo
```

### Menu

Top-nav links come from `[[menu.main]]`:

```toml
[[menu.main]]
  name = "Writing"
  url  = "/"
  weight = 10
[[menu.main]]
  name = "Archive"
  url  = "/posts/"
  weight = 20
[[menu.main]]
  name = "Tags"
  url  = "/tags/"
  weight = 30
[[menu.main]]
  name = "Services"
  url  = "/services/"
  weight = 35
[[menu.main]]
  name = "About"
  url  = "/about/"
  weight = 40
```

## Home layouts

| Value | Look |
|---|---|
| `column` | Classic centred reading column. Hero + a list of post items. |
| `broadsheet` | Newspaper-style: feature lead with optional cover image, sidebar, three-column lower deck. |
| `index` | Dense, year-grouped ledger of every post. Text-only, deliberately restrained. |

## Posts

Posts live under `content/posts/`. Example front matter:

```yaml
---
title: "On the discipline of leaving things unfinished"
date: 2026-04-12
postkind: Essay                    # Essay | Note | Link | Technical — drives the kicker + index pill
dek: "A year-long argument with myself about drafts."
toc: true                          # default true; set false to suppress on long posts
tags: [craft, writing, drafts]
categories: [Craft]

# Optional cover image — rendered as a hero on the single post,
# and as a thumbnail on the broadsheet feature lead.
cover:        /images/covers/drafts.jpg
coverAlt:     "A stack of half-finished notebooks"
coverCaption: "Field studies in what not to finish"
coverCredit:  "Photo by Some One"

# Link posts — optional
link: "https://example.com/thing"

# Home-page placement — optional, both default to false
pinned:      false   # true → promote to the top of every home layout (becomes the broadsheet feature)
hideOnHome:  false   # true → exclude from all home layouts; still in /posts/, tags, and RSS

# Typography — optional
dropcap:     true    # default; set false to suppress the oversized first letter on this post

# Series — optional. Posts sharing the same series string form an ordered sequence.
series:      ["Building a Platform"]
seriesOrder: 2

# See also — optional. List of absolute content paths. Renders above prev/next.
relatedPosts:
  - /posts/another-essay/
  - /posts/yet-another/
---
```

> Hugo ≥ 0.144 reserved `kind` as a front-matter keyword, so this theme uses
> **`postkind`** instead.

### Home placement: `pinned` and `hideOnHome`

Two independent flags control what shows up on the home page:

- **`pinned: true`** — promote the post to the top. On `broadsheet`, it becomes the
  feature lead. On `column`, it's the first item. On `index` (V3), it appears in
  its actual year (V3 re-groups by year, so pinning doesn't move it visually, but it
  remains included). Multiple pinned posts keep their relative date order.
- **`hideOnHome: true`** — exclude entirely from all three home layouts. The post
  still appears in:
  - the `/posts/` archive (what the "Archive" menu links to)
  - every tag and category page it belongs to
  - the RSS feed

Use `hideOnHome` for drafts, imports, or anything you want in the archive but not
front-of-house. Use `pinned` to promote an evergreen introduction, a pinned
announcement, or a flagship essay.

Both flags are read by `partials/home-posts.html`, which the three home templates
now call instead of listing posts directly.

### Series: multi-part posts

Declare a post as part of a named series. A banner at the top of every post in the
series lists every part in order, with the current one highlighted.

```yaml
series: ["Building a Platform"]   # multiple posts sharing this string form the series
seriesOrder: 2                    # integer; determines order within the series
```

What you get:

- **Series box** near the top of each post — "Series · Part 2 of 5", series title,
  and a numbered list of all parts (the current part says `← you are here`).
- **`/series/`** — list of every series on the site (uses the tag-cloud template).
- **`/series/<slug>/`** — landing page for one series, parts shown in `seriesOrder`
  ascending (not by date). Uses `layouts/taxonomy/series.html`.
- `series` is a standard Hugo taxonomy (`[taxonomies] series = "series"` in `hugo.toml`),
  so everything Hugo does with taxonomies — RSS, `.GetTerms`, cross-linking — works.

A post can belong to more than one series by listing multiple strings, but the
banner shows only the first.

### See also: manual cross-references

```yaml
relatedPosts:
  - /posts/other-essay/
  - /posts/yet-another/
```

Rendered as a small "See also" block at the bottom of the post, above prev/next.
Each path is resolved via `site.GetPage`; missing paths are silently skipped. Use
for hand-curated thematic links — not for algorithmic "related posts."

### What each `postkind` changes

- **Essay** — default. Kicker reads "Essay".
- **Note** — short-form. Same rendering, different kicker.
- **Link** — on list views, the title gets an `→` prefix in accent colour.
- **Technical** — same rendering, different kicker.

### Page bundles work fine

Drop `content/posts/my-post/index.md` + `my-post/cover.jpg` alongside each
other and reference `./cover.jpg` from the markdown or front matter.

### Single-post features

- Sticky **table of contents** on the left at ≥ 1100 px (auto-shown if the
  generated ToC is > 200 chars and `toc: true`).
- **Meta rail** on the right with published date, reading time / word count,
  category / kind, and a copy-link button.
- **Cover image** between header and body (see above).
- **Prev / next** navigation at the bottom of each post.
- **Tag chips** after the body.

Everything collapses cleanly to a single column on mobile.

## Pages (`type: page`)

Use for static pages like About or Colophon.

```yaml
---
title: "About"
date: 2026-01-01
type: page
layout: single
avatar: /images/portrait.jpg       # optional; placeholder pattern if omitted
kicker: "Colophon & about"         # optional accent-colour label above the title
tags: [about]                      # optional
---
```

The template renders: kicker (if any), H1, a 1:2 grid of avatar + bio content.

## Services portal (`layout: services`)

A directory-of-things page, shipped as `content/services.md`. Sections + cards,
or a flat list of cards. Each card is a clickable tile that opens in a new tab.

```yaml
---
title: "Services"
kicker: "What I run"
layout: services
description: "A small directory of the tools I host."
sections:
  - title: "Code & writing"
    note: "Where text and diagrams get drafted."
    services:
      - name: "GitLab"
        url:  "https://gitlab.example.com"
        desc: "My git forge."
        image: /images/logos/gitlab.png
        status: online                 # online | maintenance | offline
        statusLabel: "Online"          # optional — overrides the auto label
      - name: "HedgeDoc"
        url:  "https://md.example.com"
        desc: "Collaborative Markdown notepad."
        image: /images/logos/hedgedoc.png
        status: online
  - title: "Files & sharing"
    services:
      - name: "Nextcloud"
        url: "https://file.example.com"
        desc: "Files, calendar, contacts."
        image: /images/logos/nextcloud.png
        status: online
---
```

A flat `services:` list at the top level (no `sections`) also works.

### Fields per service

| Key | Required | Notes |
|---|---|---|
| `name` | ✓ | Display name on the card. |
| `url`  | ✓ | Target URL. Host is extracted for the card footer. |
| `desc` |   | One or two sentences, Markdown-rendered. |
| `image` |   | Logo path. If omitted, a hatched placeholder with `[ name ]` is shown. |
| `status` |   | `online` (default, green dot) · `maintenance` or `offline` (red dot). |
| `statusLabel` |   | Overrides the dot's text. |

### Logos

Service logos live under `static/images/logos/`. See
`static/images/logos/README.md` for:

- Where to source logos (apple-touch-icon > upstream project > Simple Icons).
- How to convert `.ico` / `.png` / `.svg` to the right format (ImageMagick recipes).
- What sizes actually look good in the 16:10 thumb slot.

## Taxonomies, archive, RSS, 404

All driven by stock Hugo features.

| Path | What |
|---|---|
| `/posts/` | Year-grouped list of every post (`_default/list.html`). Also used by the "Archive" menu link. |
| `/tags/` | Tag cloud, weighted by post count (`_default/terms.html`). |
| `/tags/<tag>/` | Year-grouped list of posts in that tag (same list template). |
| `/categories/` and `/categories/<cat>/` | Same as tags, wired through `[taxonomies]` in `hugo.toml`. |
| `/index.xml`, `/posts/index.xml`, `/tags/<tag>/index.xml` | RSS feeds. Enabled in `[outputs]`. |
| Any missing URL | `layouts/404.html`. |

## Static assets & images

- **`static/`** — copied verbatim to the site root at build time.
  - `static/images/portrait*.jpg` — avatar candidates for the about page.
  - `static/images/covers/*.jpg` — cover image suggestions for posts.
  - `static/images/logos/*.{png,svg}` — service card logos.
- **`themes/lantern/static/`** — theme-level static assets (CSS, JS). Copied to
  site root and overridable by the same path in your site's `static/`.

## Icons in Markdown

`enableEmoji = true` is set, so Goldmark's emoji shortcodes are live:

```markdown
:round_pushpin: Bastion host   → 📍 Bastion host
:dart: Crosshairs              → 🎯 Crosshairs
:compass: Navigation           → 🧭 Navigation
```

Hugo has **no built-in equivalent for Font Awesome / Material icon shortcodes**
(`:fontawesome-solid-x:`, `:material-y:`). If you import content from MkDocs
Material, you have four options in order of effort:

1. One-shot `sed` over the imported file, replacing the tokens with either a
   Unicode emoji or inline SVG.
2. Template-level regex replace in `_default/single.html`, e.g.
   `{{ .Content | replaceRE ":fontawesome-solid-([a-z0-9-]+):" "<i class=\"fa-solid fa-$1\"></i>" | safeHTML }}`
   plus a Font Awesome CSS `<link>` in `baseof.html`.
3. A custom Hugo shortcode (`{{< icon ... >}}`) that embeds real SVGs from
   `assets/icons/`.
4. The [Iconify](https://iconify.design) web component: one `<script>` tag
   and then `<iconify-icon icon="fa-solid:location-crosshairs"></iconify-icon>`
   anywhere.

## Hugo compatibility

Every template function used (`.TableOfContents`, `.ReadingTime`,
`.Pages.GroupByDate`, `.Data.Terms.Alphabetical`, `.OutputFormats.Get`,
`.IsMenuCurrent`, `now.Format`, `delimit`, `first`, `after`, `urls.Parse`,
`markdownify`, `safeHTML`, `replaceRE`, etc.) is a standard Hugo construct.
OKLCH colours, `clamp()` typography, and CSS custom properties are
browser-level features, not Hugo features.

Built and verified against **Hugo 0.160.0 extended**. Minimum supported Hugo:
**0.144.0** (because of the `kind` front-matter rename). Hugo *extended* is
recommended so PostCSS / SCSS hooks are available if you extend the theme.

Two small upgrade deltas from the upstream bundle:

- Front-matter `kind:` → `postkind:` everywhere (Hugo ≥ 0.144).
- `.Site.LanguageCode` → `.Site.Language.Lang` in `baseof.html` (deprecated
  since Hugo 0.158).

## License

The theme (`themes/lantern/`) is under the theme's own licence (MIT by
default, see `themes/lantern/theme.toml`). The example content is placeholder
prose. Service logos in `static/images/logos/` are trademarks of their
respective projects; included for identification in a directory-of-services
context and easily replaceable.
