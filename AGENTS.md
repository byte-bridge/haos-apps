# Agent instructions

This file provides context for AI agents (Cursor, Copilot, etc.) working in this repository.

## What this repo is

**haos-apps** is a [Home Assistant app repository](https://developers.home-assistant.io/docs/apps/) that packages third-party services as installable apps on Home Assistant OS (HAOS).

- **Repository URL:** `https://github.com/byte-bridge/haos-apps`
- **Registry file:** `repository.yaml` at the repo root
- **Each app:** a top-level folder with its own `config.yaml` (e.g. `rancher/`)

## Repository layout

```
repository.yaml       # HA repo manifest — do not put apps inside subfolders
<app-slug>/           # One folder per app at repo root
  config.yaml         # App manifest (required)
  Dockerfile          # Build instructions
  DOCS.md             # User documentation
  README.md           # Store listing intro
  CHANGELOG.md
  icon.png / logo.png
  translations/en.yaml
  rootfs/             # s6-overlay scripts (if using hassio-addons base)
templates/app/        # Scaffold for new apps — copy, don't edit in place
docs/                 # Shared docs (install, contributing, adding apps)
.cursor/rules/        # Cursor-specific rules
```

**Important:** Home Assistant expects app folders at the repository root, not under `apps/`. Do not nest apps in subdirectories.

## Adding a new app

1. `cp -r templates/app <slug>` then `mv <slug>/config.yaml.example <slug>/config.yaml`
2. Update `config.yaml` (`name`, `slug`, `version`, `description`, `url`)
3. Implement `Dockerfile` and `rootfs/`
4. Write `DOCS.md` and `CHANGELOG.md`
5. Add row to root `README.md` apps table
6. Test on HAOS (copy folder to `/addons/<slug>`, check for updates)

See `docs/ADDING_AN_APP.md` for the full checklist.

## Official blueprint: apps-example

The Home Assistant template is [home-assistant/apps-example](https://github.com/home-assistant/apps-example). Use it for **repository and app packaging**, not for Rancher’s Docker/k3s runtime.

**Copy from apps-example**

- Repo layout: `repository.yaml` plus one folder per app at the root (`example/` → our `rancher/`)
- App files: `config.yaml`, `Dockerfile`, `DOCS.md`, `CHANGELOG.md`, `icon.png` / `logo.png`, `translations/en.yaml`, `rootfs/etc/services.d/.../run|finish`
- `slug` must match the folder name; `init: false` when using s6
- `image:` in `config.yaml` when publishing to a container registry (GHCR)
- CI: `.github/workflows/build-app.yaml`, `builder.yaml`, `lint.yaml`
- Optional: `apparmor.txt` for a custom AppArmor profile

**Do not copy from apps-example for rancher/**

The example app is a tiny in-container program. Rancher is a **privileged Docker wrapper** (`docker run rancher/rancher`). For that, follow `rancher/` in this repo and the [single-node Docker install](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker/). apps-example has no `docker_api`, Ingress nginx, or `--privileged` host container.

## Conventions

### config.yaml

- Use `config.yaml` (not `config.json`) for new apps
- `slug` must match the folder name and be URI-safe
- Pin versions as semver strings: `"1.0.0"`
- Link `url` to the app's docs: `https://github.com/byte-bridge/haos-apps/tree/main/<slug>`

### Docker / rootfs

- Scripts: `#!/usr/bin/with-contenv bashio`, LF line endings, `chmod +x`
- Persistent data: `/data` inside the app container
- User config: `/data/options.json` (read via `bashio::config`)
- Ingress: listen on port `8099`, allow only `172.30.32.2`

### Base images

- **hassio-addons/base** — s6-overlay + bashio (used by `rancher/`). Pin a release tag (`ghcr.io/hassio-addons/base:21.0.3`). `.github/workflows/sync-app-base.yaml` bumps it from [app-base releases](https://github.com/hassio-addons/app-base/releases).
- **home-assistant/{arch}-base** — official HA base
- **Upstream image** — use `image:` + `legacy: true` + `init: false`

### Security-sensitive apps

Apps needing Docker API or privileged access must:

- Set `advanced: true`
- Call `bashio::require.unprotected` in cont-init
- Document that users must disable Protection mode
- Warn that HAOS may become unsupported

## Existing apps

### rancher/

Wraps the official `rancher/rancher` Docker image via host Docker API.

- **Pattern:** Docker orchestration wrapper + nginx ingress proxy
- **Requires:** `full_access`, `docker_api`, `host_network`, Protection mode off
- **Key files:** `rootfs/etc/services.d/rancher/run`, `rootfs/etc/services.d/nginx/run`
- **Upstream:** https://www.rancher.com/quick-start

## What NOT to do

- Don't nest apps under `apps/` or `packages/`
- Don't commit secrets, `.env` files, or bootstrap passwords
- Don't use `config.yaml` as a filename anywhere except the app manifest
- Don't pin Alpine package versions unless necessary (they go stale)
- Don't create git commits unless the user asks

## Useful links

- [HA app docs](https://developers.home-assistant.io/docs/apps/)
- [App configuration reference](https://developers.home-assistant.io/docs/apps/configuration)
- [Ingress guide](https://developers.home-assistant.io/docs/apps/presentation#ingress)
- [apps-example](https://github.com/home-assistant/apps-example) — official repo/app blueprint
- [hassio-addons/app-base](https://github.com/hassio-addons/app-base) — Alpine + s6 + bashio
- [hassio-addons/bashio](https://github.com/hassio-addons/bashio)
