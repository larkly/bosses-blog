# hugo-newblog-design

An example Hugo site that ships with the **Lantern** theme — an editorial blog
design originating from Claude Design (`simple-hugo-blog`). Three home layouts,
dark / light / auto mode, OKLCH accents, typographic focus.

## Layout

```
.
├── hugo.toml              # Site config (points at the lantern theme)
├── content/
│   ├── about.md           # About page (uses page/single layout)
│   └── posts/             # Example posts spanning Essay · Note · Link · Technical
└── themes/
    └── lantern/           # The theme itself
        ├── theme.toml
        ├── config.example.toml
        ├── layouts/
        │   ├── 404.html
        │   ├── _default/{baseof,list,single,terms}.html
        │   ├── index.html
        │   ├── page/single.html
        │   └── partials/{header,footer,post-item}.html
        │   └── partials/home/{column,broadsheet,index}.html
        └── static/{css,js}/
```

## Running

```
hugo server
# or a plain build:
hugo
```

Then open `http://localhost:1313`.

## Switching home layouts

```toml
# hugo.toml
[params]
homeLayout = "column"      # column | broadsheet | index
```

- **column** — classic centered reading column with floating meta rail.
- **broadsheet** — asymmetric two-column newspaper / journal feel.
- **index** — dense year-grouped archive home.

You can also override via environment variable at build time:

```
HUGO_PARAMS_HOMELAYOUT=broadsheet hugo server
```

## Theming knobs

All exposed in `[params]`:

| Key | Values | Purpose |
|---|---|---|
| `homeLayout` | `column` · `broadsheet` · `index` | Front page design |
| `fontPairing` | `fraunces` · `garamond` · `playfair` | Font pairing |
| `accentHue` | 0–360 | OKLCH hue |
| `accentChroma` / `accentLight` | numbers | OKLCH chroma + lightness |
| `readWidth` | ch (e.g. 64) | Reading column width |
| `defaultTheme` | `auto` · `light` · `dark` | Default theme (user can override) |
| `postsOnHome` | int | Posts on the column home |

## Front matter

```yaml
title: "On the discipline of leaving things unfinished"
date: 2026-04-12
postkind: Essay          # Essay | Note | Link | Technical — drives the kicker + index pill
dek: "A year-long argument with myself about drafts."
toc: true                # default true; set false to suppress on long posts
tags: [craft, writing, drafts]
categories: [Craft]
```

> Note: we use `postkind` rather than `kind` because Hugo ≥ 0.144 reserved
> `kind` in front matter.

## Hugo compatibility

Every template function in the theme (`.TableOfContents`, `.ReadingTime`,
`.Pages.GroupByDate`, `.Data.Terms.Alphabetical`, `.OutputFormats.Get`,
`.IsMenuCurrent`, `now.Format`, `delimit`, `first`, `after`, etc.) is a standard
Hugo construct. OKLCH colors, `clamp()` typography, and CSS custom properties
are browser-level features, not Hugo features.

Built and verified against **Hugo 0.160.0 extended**. Minimum supported Hugo:
`0.144.0` (because of the `kind` front-matter rename). Hugo *extended* is
recommended so PostCSS / SCSS hooks are available if you extend the theme.

## License

The theme (`themes/lantern/`) is under the theme's own license (MIT by default,
see `themes/lantern/theme.toml`). The example content is placeholder prose.
