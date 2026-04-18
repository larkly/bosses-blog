# Service logos

Each service card on `/services/` expects a logo in this folder. The card CSS
(`.service-card__thumb`) renders them as `object-fit: contain` inside a
16:10 slot with `padding: 1rem` — so logos breathe, but anything under
~180 px on its longest side will look soft when upscaled.

## What's "optimal" for this page

- **SVG** — the best option whenever available. Scales perfectly, tiny
  files (1–10 KB). Use for anything with a vector source.
- **PNG, 180×180 or larger** — second-best. `apple-touch-icon.png` from a
  service's own HTML head is usually 180×180 and fits perfectly. A 256×256
  or 512×512 PNG (e.g. Nextcloud's `/apps/theming/icon`) is ideal.
- **Avoid**: `.ico` files, 16×16 or 32×32 favicons, anything under ~96 px.
  They will upscale to pixelated mush.

## Finding the best source

In priority order:

1. **Your own instance's apple-touch-icon.** Most self-hosted apps expose
   it at `/apple-touch-icon.png`:
   ```bash
   curl -sko gitlab.png https://gitlab.klykken.com/apple-touch-icon.png
   ```
2. **The service's HTML `<link rel="icon">` tags.** Load the homepage,
   grep for `<link>` elements, pick the biggest candidate:
   ```bash
   curl -sk https://md.klykken.com | grep -oE '<link[^>]*icon[^>]*>'
   ```
3. **Upstream project site or GitHub.** Official logos are usually at the
   project's main domain or in the repo (often `/assets/logo.svg` or
   `/build/icon.png`). Example:
   ```bash
   curl -sko drawio.svg https://app.diagrams.net/images/drawlogo.svg
   curl -sko hedgedoc.png https://hedgedoc.org/icons/apple-touch-icon.png
   ```
4. **Wikipedia / Simple Icons** as a last resort. Simple Icons has
   monochrome SVGs of most well-known FLOSS tools:
   ```bash
   curl -sko gitlab.svg https://cdn.simpleicons.org/gitlab
   ```

## Converting formats with ImageMagick

`magick` (ImageMagick 7) or `convert` (ImageMagick 6) handles everything.

### `.ico` → `.png`

`.ico` files often contain multiple sizes. Pick the largest:

```bash
# Inspect what sizes are inside
magick identify send.ico
# send.ico[0] PNG 48x48 ...
# send.ico[1] PNG 32x32 ...

# Extract the largest (index 0 here, since magick lists them big→small)
magick 'send.ico[0]' send.png
```

Or, shorter — `convert` picks the largest automatically with `-resize`:

```bash
magick send.ico -resize 180x180 send.png
```

### Upscale a small PNG (best-effort)

Don't try to add detail that isn't there, but you can smooth it a bit:

```bash
magick drawio-32.png -filter Lanczos -resize 180x180 drawio.png
```

If it still looks fuzzy, the source is too small — find a better one.

### Strip metadata + optimise PNG

```bash
magick logo.png -strip -define png:compression-level=9 logo.png
# Or use dedicated tools:
oxipng -o max logo.png      # lossless, smaller
pngquant --quality=75-95 logo.png --output logo.png  # lossy, much smaller
```

### SVG → PNG (if you need a raster for some reason)

```bash
magick -background none -density 300 logo.svg -resize 256x256 logo.png
# Or with librsvg (usually cleaner):
rsvg-convert -h 256 logo.svg > logo.png
```

### PNG / JPG → SVG

**You can't, usefully.** Raster → vector requires retracing (Inkscape's
"Trace Bitmap", or `potrace` on black-and-white shapes). For brand
logos, always find the real SVG instead.

## Quick quality check

```bash
# list dimensions + filesize for every logo
magick identify -format "%f  %wx%h  %b\n" *.png *.svg
```

Anything under 96 px wide is a candidate for replacement.
