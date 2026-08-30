# Agent instructions

This file provides context for AI agents (Cursor, Copilot, etc.) working in this repository.

## What this repo is

**haos-apps** is a [Home Assistant app repository](https://developers.home-assistant.io/docs/apps/) that packages third-party services as installable apps on Home Assistant OS (HAOS).

- **Repository URL:** `https://github.com/byte-bridge/haos-apps`
- **Registry file:** `repository.yaml` at the repo root
- **Each app:** a top-level folder with its own `config.yaml` (e.g. `rancher/`)

## Target platform: Home Assistant OS

This repo targets **Home Assistant OS (HAOS)**, not Home Assistant Supervised or Home Assistant Container.

See [docs/HOME_ASSISTANT_ADRS.md](docs/HOME_ASSISTANT_ADRS.md) for how [Home Assistant ADRs](https://github.com/home-assistant/architecture/tree/master/adr) map to this repo. Summary:

| ADR | Method | Use for haos-apps? |
|-----|--------|-------------------|
| [0015 HAOS](https://github.com/home-assistant/architecture/blob/master/adr/0015-home-assistant-os.md) | Home Assistant OS | **Yes — primary target** |
| [0014 Supervised](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md) | Supervised | **No — reverted** |
| [0013 Container](https://github.com/home-assistant/architecture/blob/master/adr/0013-home-assistant-container.md) | Container | **No — no Supervisor / no apps** |

[ADR-0014](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md) defined Supervised (HA on a dedicated Debian host with Supervisor). That ADR is **reverted** by [discussion #1198](https://github.com/home-assistant/architecture/discussions/1198): Supervised is no longer an officially supported install method (deprecated from HA 2025.6).

Do not:

- Treat Supervised as a supported target or test matrix
- Apply old Supervised Docker rules as HAOS requirements (the ADR required overlayfs2, journald, and **cgroup v1** on the host). HAOS is its own OS and typically uses **cgroup v2**. Do not add k3s/cgroup v1 workarounds “because Supervised said so.”
- Document install steps that assume a user-managed Debian + Docker CE host

Apps that start extra host containers (Rancher) already sit outside what Home Assistant supports on HAOS. Keep that warning in `DOCS.md`.

## Repository layout

```
repository.yaml       # HA repo manifest — do not put apps inside subfolders
AGENTS.md             # Repo-wide agent instructions (this file)
<app-slug>/           # One folder per app at repo root
  AGENTS.md           # App-specific agent instructions (nested; auto-applies in that tree)
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
.cursor/rules/        # Cursor project rules (always-apply + glob-scoped)
```

**Important:** Home Assistant expects app folders at the repository root, not under `apps/`. Do not nest apps in subdirectories.

### Agent instructions (Cursor)

Per [Cursor Rules](https://cursor.com/docs/rules):

| Layer | Location | Scope |
|-------|----------|--------|
| Repo-wide | `AGENTS.md` (root) | Always available for the project |
| Per app | `<slug>/AGENTS.md` | Applies when working in that folder or its children |
| Project rules | `.cursor/rules/*.mdc` | `alwaysApply` or `globs` (packaging conventions) |

When editing an app, follow **root + that app’s** `AGENTS.md`. Nested instructions take precedence on conflicts.

## Adding a new app

1. `cp -r templates/app <slug>` then `mv <slug>/config.yaml.example <slug>/config.yaml`
2. Update `config.yaml` (`name`, `slug`, `version`, `description`, `url`)
3. Fill in `<slug>/AGENTS.md` (replace the scaffold stub)
4. Implement `Dockerfile` and `rootfs/`
5. Write `DOCS.md` and `CHANGELOG.md`
6. Add rows to root `README.md` and this file’s **Existing apps** table
7. Test on HAOS (copy folder to `/addons/<slug>`, check for updates)

See `docs/ADDING_AN_APP.md` for the full checklist.

## Official blueprint: apps-example

The Home Assistant template is [home-assistant/apps-example](https://github.com/home-assistant/apps-example). Use it for **repository and app packaging**, not for privileged host-Docker runtimes.

**Copy from apps-example**

- Repo layout: `repository.yaml` plus one folder per app at the root (`example/` → our `<slug>/`)
- App files: `config.yaml`, `Dockerfile`, `DOCS.md`, `CHANGELOG.md`, `icon.png` / `logo.png`, `translations/en.yaml`, `rootfs/etc/services.d/.../run|finish`
- `slug` must match the folder name; `init: false` when using s6
- `image:` in `config.yaml` when publishing to a container registry (GHCR)
- CI: `.github/workflows/build-app.yaml`, `builder.yaml`, `lint.yaml`
- Optional: `apparmor.txt` for a custom AppArmor profile

App-specific runtime rules (e.g. Rancher’s Docker wrapper) live in that app’s `AGENTS.md`, not here.

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

### App changes: CHANGELOG and commits

When you ship a change to an app (behavior, packaging, or docs that accompany a version bump):

1. Bump `version` in `<slug>/config.yaml`.
2. Add the release notes to `<slug>/CHANGELOG.md` ([Keep a Changelog](https://keepachangelog.com/) — `Added`, `Changed`, `Fixed`, `Removed`).
3. When creating a git commit, **use that new CHANGELOG section as the commit message** — do not write a separate summary.

Commit message format (copy the new section verbatim; prefix the subject with the app slug and version):

```
<slug> <version>

### Changed

- Bullet from CHANGELOG
```

Example for `rancher` 1.0.8:

```
rancher 1.0.8

### Changed

- `reset_data` is cleared automatically after wiping the Rancher volume so a one-time reset does not repeat on every boot.
```

One app per commit when possible. Repo-wide changes (CI, docs outside any app, `repository.yaml`) use a normal imperative subject instead.

## Existing apps

| App | Agent instructions | Pattern |
|-----|-------------------|---------|
| `rancher/` | [rancher/AGENTS.md](rancher/AGENTS.md) | Privileged Docker wrapper + Ingress nginx |

Add a row here when you add an app, and ship `<slug>/AGENTS.md` with the copy from `templates/app/`.

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
- [ADR-0014 (Supervised, reverted)](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md) — do not target Supervised
- [Discussion #1198](https://github.com/home-assistant/architecture/discussions/1198) — decision to drop Supervised support
- [ADR-0015 (HAOS)](https://github.com/home-assistant/architecture/blob/master/adr/0015-home-assistant-os.md) — primary target
- [All Home Assistant ADRs](https://github.com/home-assistant/architecture/tree/master/adr) — see [docs/HOME_ASSISTANT_ADRS.md](docs/HOME_ASSISTANT_ADRS.md)
