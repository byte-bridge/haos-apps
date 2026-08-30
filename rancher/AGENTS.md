# Rancher app — agent instructions

Applies when working under `rancher/`. Combine with the root [AGENTS.md](../AGENTS.md).

## What this app is

Privileged **Docker orchestration wrapper** around the official `rancher/rancher` image, plus nginx for Home Assistant Ingress.

- Upstream: [single-node Docker install](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker/) (dev/test only)
- Quick start: https://www.rancher.com/quick-start
- User docs: [DOCS.md](DOCS.md)

## Do not copy apps-example runtime

[home-assistant/apps-example](https://github.com/home-assistant/apps-example) is the packaging blueprint only. That example runs a tiny program **inside** the app container. This app starts `rancher/rancher` on the **host Docker** API (`docker run … --privileged`). apps-example has no `docker_api`, Ingress nginx, or host Rancher container.

## Capabilities (required)

| Flag / option | Why |
|---------------|-----|
| `advanced: true` | Privileged / Docker API app |
| `docker_api: true` | Start/manage host Rancher container |
| `full_access: true` | Hardware / host access |
| `host_network: true` | Rancher networking |
| Protection mode **off** | Required; enforced in cont-init |

In cont-init: call `bashio::require.unprotected`. Keep the unsupported-HAOS warning in `DOCS.md`.

## Architecture

1. **cont-init** (`rootfs/etc/cont-init.d/`) — require unprotected mode, prepare nginx / Rancher options
2. **rancher service** (`rootfs/etc/services.d/rancher/run`) — `docker run` / attach to host container from options (`rancher_version`, ports, bootstrap password, etc.)
3. **nginx service** (`rootfs/etc/services.d/nginx/run`) — Ingress on `8099`, allow only `172.30.32.2`, proxy to Rancher HTTP port

Persistent data lives on the host volume used by the Rancher container; app options are in `/data/options.json`.

## Key files

- `config.yaml` — manifest (`slug: rancher` must match folder)
- `Dockerfile` — hassio-addons base + docker CLI + nginx
- `rootfs/etc/services.d/rancher/run` | `finish`
- `rootfs/etc/services.d/nginx/run`
- `rootfs/etc/nginx/` — Ingress proxy config
- `rootfs/etc/cont-init.d/rancher.sh`, `nginx.sh`

## Conventions for this app

- Scripts: `#!/usr/bin/with-contenv bashio`, LF, executable
- Do not commit bootstrap passwords or `.env` secrets
- Prefer matching existing `docker run` flags and nginx Ingress patterns over inventing new ones
- Target **HAOS only** — do not add Supervised / cgroup v1 workarounds

## Versioning

When shipping behavior or packaging changes:

1. Bump `version` in `config.yaml`.
2. Add a [Keep a Changelog](https://keepachangelog.com/) section to `CHANGELOG.md`.
3. Use that new section as the git commit message (see root [AGENTS.md](../AGENTS.md#app-changes-changelog-and-commits)).
