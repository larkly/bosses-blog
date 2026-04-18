# bosses-blog

Personal Hugo site — source for [klykken.com](https://klykken.com). Ships
with the **[Lantern](themes/lantern/)** theme (editorial, three home layouts,
dark/light/auto, OKLCH accents). Built into a static container image on every
push and published to GHCR for a Traefik-fronted deployment.

- [Stack](#stack)
- [Local development](#local-development)
- [Site configuration](#site-configuration)
- [Authoring posts](#authoring-posts)
  - [Leaf bundles](#leaf-bundles)
  - [Cover images](#cover-images)
  - [Home placement & nav](#home-placement--nav)
- [Container build](#container-build)
  - [Dockerfile](#dockerfile)
  - [GitHub Actions → GHCR](#github-actions--ghcr)
  - [Running locally](#running-locally)
- [Deploy behind Traefik](#deploy-behind-traefik)
- [Theme documentation](#theme-documentation)
- [License](#license)

## Stack

| Layer       | Tool                                                              |
| ---         | ---                                                               |
| SSG         | [Hugo](https://gohugo.io/) ≥ 0.144, extended                      |
| Theme       | [Lantern](themes/lantern/) (in-tree; intended to split out later) |
| Runtime     | nginx 1.27 (alpine)                                               |
| Image       | `ghcr.io/larkly/bosses-blog`                                      |
| CI          | GitHub Actions (multi-arch buildx → GHCR)                         |
| Edge        | Traefik + Let's Encrypt                                           |

## Local development

```sh
hugo server              # live reload at http://localhost:1313
hugo                     # production build into public/
```

`hugo.toml` is the single source of site configuration. Every `[params]` key
can also be overridden at build time via `HUGO_PARAMS_<KEY>`:

```sh
HUGO_PARAMS_HOMELAYOUT=index hugo server
HUGO_PARAMS_ACCENTHUE=210 hugo
```

## Site configuration

The relevant knobs in [`hugo.toml`](hugo.toml):

- `baseURL` — canonical origin for absolute URLs. The CI pipeline overrides
  this at build time via the `HUGO_BASEURL` build arg (see below).
- `[params].homeLayout` — `column` · `broadsheet` · `index`.
- `[params].fontPairing` — `fraunces` · `garamond` · `playfair`.
- `[params].accentHue` / `accentChroma` / `accentLight` — OKLCH accent colour.
- `[params].defaultTheme` — `auto` · `light` · `dark`. User can toggle.
- `[menu.main]` — top-nav entries.

Full reference in the [theme README](themes/lantern/README.md#site-configuration).

## Authoring posts

Posts live under `content/posts/`. See the theme README for the full
[front-matter reference](themes/lantern/README.md#front-matter); the
site-specific conventions below.

### Leaf bundles

Put anything with its own images into a leaf bundle:

```
content/posts/my-post/
├── index.md              # cover: photo.jpg
└── photo.jpg
```

Don't name the markdown file anything other than `index.md` if you want
sibling images to resolve correctly — the cover partial looks them up via
`.Resources.GetMatch`, which only works inside a leaf bundle.

### Cover images

Per-post knobs (all optional, all in front matter):

| Key            | Values                              | Purpose                                                           |
| ---            | ---                                 | ---                                                               |
| `cover`        | path or URL                         | Bundle-relative filename, leading-`/` site path, or `https://…`.  |
| `coverAlt`     | string                              | Alt text. Falls back to the post title.                           |
| `coverCaption` | string                              | Caption under the hero on single posts.                           |
| `coverCredit`  | string                              | Credit appended to the caption.                                   |
| `coverFocus`   | `"50% 30%"`, `"center top"`, …      | `object-position` — shift the crop focus.                         |
| `coverAspect`  | `16/9` (default) · `4/3` · `1/1` · `auto` | Aspect of the rendered box.                                 |
| `coverFit`     | `cover` (default) · `contain`       | Crop or letterbox.                                                |

Covers that are page resources get auto-downscaled to 1600 px max at build
time, `width`/`height` attrs are emitted for layout-stable loading, and the
wrapper caps at native width so small images never upscale.

### Home placement & nav

Two orthogonal flags:

- `pinned: true` — promote to top across all home layouts (becomes the
  broadsheet feature).
- `hideOnHome: true` — hide from **every** home layout **and** from the
  prev/next nav on single posts. The post still shows in `/posts/`, tags, and
  RSS. Use for imports, drafts-in-public, or evergreen pages you don't want in
  the reading sequence.

## Container build

### Dockerfile

Two-stage, sentinel-free:

1. `hugomods/hugo:exts-0.151.0` builds the site with `--baseURL "${HUGO_BASEURL}"`
   and `--environment "${HUGO_ENV}"`.
2. `nginx:1.27-alpine` serves the generated `public/` on port **8080**.

`daemon off;` lives in `/etc/nginx/nginx.conf`; the entrypoint is just
`nginx` (no `-g` flags), so stray `command:`/`args:` overrides from the
runtime can't inject bogus options.

Build args:

| Arg            | Default                 | Purpose                                    |
| ---            | ---                     | ---                                        |
| `HUGO_VERSION` | `0.151.0`               | Hugo builder image tag.                    |
| `HUGO_BASEURL` | `https://klykken.com`   | Baked into generated HTML at build time.   |
| `HUGO_ENV`    | `production`             | Hugo's `--environment` value.              |

Build locally:

```sh
docker build -t bosses-blog:dev --build-arg HUGO_BASEURL=http://localhost:13500 .
```

### GitHub Actions → GHCR

[`.github/workflows/container.yml`](.github/workflows/container.yml) runs on
push to `main`, semver tags (`v*.*.*`), PRs, and manual dispatch. It:

- Sets up QEMU + Buildx.
- Logs into GHCR with the ambient `GITHUB_TOKEN` (push skipped for PRs).
- Builds for `linux/amd64` **and** `linux/arm64`.
- Tags with branch, PR ref, semver, short SHA, and `latest` on the default branch.
- Caches layers via GitHub Actions cache.

The image is published to `ghcr.io/larkly/bosses-blog`.

### Running locally

```sh
podman run --rm -it -p 13500:8080 ghcr.io/larkly/bosses-blog:latest
# then open http://127.0.0.1:13500
```

Container port is **8080** (not 80). Prefer `127.0.0.1` over `localhost` on
rootless podman — the port-forward may only bind v4.

## Deploy behind Traefik

Drop into an existing Traefik stack via `docker-compose`:

```yaml
services:
  blog:
    image: ghcr.io/larkly/bosses-blog:latest
    container_name: bosses-blog
    restart: unless-stopped
    networks:
      - traefik
    labels:
      traefik.enable: "true"
      traefik.docker.network: traefik
      traefik.http.services.blog.loadbalancer.server.port: "8080"

      traefik.http.routers.blog-http.rule: Host(`klykken.com`) || Host(`www.klykken.com`)
      traefik.http.routers.blog-http.entrypoints: web
      traefik.http.routers.blog-http.middlewares: blog-https
      traefik.http.middlewares.blog-https.redirectscheme.scheme: https
      traefik.http.middlewares.blog-https.redirectscheme.permanent: "true"

      traefik.http.routers.blog.rule: Host(`klykken.com`) || Host(`www.klykken.com`)
      traefik.http.routers.blog.entrypoints: websecure
      traefik.http.routers.blog.tls: "true"
      traefik.http.routers.blog.tls.certresolver: letsencrypt

networks:
  traefik:
    external: true
```

Assumes: Traefik has `web` + `websecure` entrypoints and a `letsencrypt` cert
resolver, and the `traefik` external network exists. Rename to taste.

## Theme documentation

All theme-level concerns — front-matter reference, home layouts, series,
services portal, alerts, CSS custom properties, directory layout — live in
the theme's own README: [themes/lantern/README.md](themes/lantern/README.md).
The theme is MIT-licensed and intended to split out into its own repo.

## License

- **Theme** (`themes/lantern/`) — MIT, see
  [themes/lantern/LICENSE](themes/lantern/LICENSE).
- **Content** (`content/`, `static/`) — © Bosse Klykken. All rights reserved
  unless noted otherwise on individual posts.
- **Service logos** (`static/images/logos/`) — trademarks of their respective
  projects; included for identification only.
