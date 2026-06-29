# bosses-blog — INDEX

Personal Hugo site for [klykken.com](https://klykken.com), built with the Lantern theme and deployed as a container image to GHCR.

## Content

| File | Description |
|------|-------------|
| [README.md](README.md) | Project overview, stack, local dev, site config, authoring posts, container build, deploy |
| [hugo.toml](hugo.toml) | Hugo site configuration (theme, params, font, accent) |
| [Dockerfile](Dockerfile) | Multi-stage container build (Hugo → nginx alpine) |

### Pages

| Path | Description |
|------|-------------|
| [content/about.md](content/about.md) | About page |
| [content/services.md](content/services.md) | Services page |
| [content/posts/2026-04-first/index.md](content/posts/2026-04-first/index.md) | Blog post: first entry (April 2026) |
| [content/posts/rh-ocp-on-vsphere.md](content/posts/rh-ocp-on-vsphere.md) | Blog post: Red Hat OpenShift on vSphere |

### Static assets

| Path | Description |
|------|-------------|
| [static/images/logos/README.md](static/images/logos/README.md) | Logo image index |
| `static/images/portrait*.jpg` | Author portraits |

## CI/CD

- **Workflow:** [container.yml](.github/workflows/container.yml) — builds Hugo site, creates container image, pushes to `ghcr.io/larkly/bosses-blog`
- **Deploy:** Traefik-fronted deployment pulling from GHCR

## Theme

Lantern (in-tree at `themes/lantern/`): editorial theme with three home layouts, dark/light/auto mode, OKLCH accent colors.
