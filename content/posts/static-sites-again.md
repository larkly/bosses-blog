---
title: "Static sites, again"
date: 2025-06-14
postkind: Technical
dek: "Why I keep coming back to flat HTML after every attempt to outgrow it."
toc: true
tags: [web, ssg, hugo]
categories: [Technical]
---

I have, at various points, convinced myself that I needed:

- a database
- a CMS
- server-side rendering
- an edge function
- a headless architecture

Every time I convinced myself, I was wrong. The thing I actually needed was flat
HTML files on a cheap host. Every time.

## What "enough" looks like

For a personal blog, "enough" is:

- Markdown files in a folder
- A build step that turns them into HTML
- A cheap CDN or static host (Netlify, Cloudflare Pages, even GitHub Pages)

That's it. You do not need edge functions. You do not need ISR. You do not need a
database to hold the three tags you use.

## The Hugo sweet spot

Hugo in particular hits a sweet spot I haven't found elsewhere:

1. Build times that stay fast even at 500+ posts.
2. A template language that's ugly but stable — it hasn't broken in years.
3. Single-binary distribution. No Node version fighting.

The tradeoff: the Go template syntax is unpleasant to write. I've made my peace with it.

## A pattern I like

Keep your design tokens in `config.toml` under `[params]`, expose them to your base
template, and let the site author theme the place without touching CSS. This theme
does it — accent hue, font pairing, reading width, home layout are all config
parameters. Someone cloning it can rebrand the whole site without opening a
template file.

That's the static-site ideal: the author changes *data*, and the shape of the site
follows from it.
