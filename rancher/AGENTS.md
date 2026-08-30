# Rancher app — agent instructions

Applies when working under `rancher/`. Combine with the root [AGENTS.md](../AGENTS.md).

## What this app is

Thin **Home Assistant wrapper** around the upstream [`rancher/rancher`](https://hub.docker.com/r/rancher/rancher) image. Rancher and embedded k3s run **inside the app container** — no host `docker run`, no hassio-addons base, no s6.

- Upstream: [single-node Docker install](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker/) (dev/test only)
- Upstream packaging: [rancher/rancher `package/entrypoint.sh`](https://github.com/rancher/rancher/blob/main/package/entrypoint.sh) — synced into `rootfs/usr/local/bin/rancher-entrypoint.sh` (HAOS cgroup skip)
- User docs: [DOCS.md](DOCS.md)

## Architecture

```
Supervisor app container (FROM rancher/rancher:stable)
├── haos-entrypoint.sh     # /data bind, options, reset_data, k3s compat env
├── Caddy on :8099         # HA Ingress gateway → 127.0.0.1:80 + proxy headers
└── entrypoint.sh (upstream) → catatonit → rancher + embedded k3s
```

Persistent data: `/data/rancher` bind-mounted to `/var/lib/rancher` (Supervisor `/data` volume).

## Capabilities (required)

| Flag / option | Why |
|---------------|-----|
| `advanced: true` | Privileged Rancher / k3s workload |
| `full_access: true` | Required for k3s; Protection mode must be off |
| `hassio_api: true` | Clear `reset_data` via Supervisor API after wipe |
| Protection mode **off** | Enforced in entrypoint |

Do **not** use `docker_api` or `host_network` — removed in 2.0.0.

## Key files

- `Dockerfile` — `FROM rancher/rancher:${RANCHER_TAG}` + static Caddy/jq
- `rootfs/usr/local/bin/haos-entrypoint.sh` — main entrypoint
- `rootfs/usr/local/bin/rancher-entrypoint.sh` — upstream `entrypoint.sh` + HAOS read-only cgroup skip
- `rootfs/usr/local/lib/haos-rancher/options.sh` — read `/data/options.json`, Supervisor API
- `rootfs/etc/caddy/Caddyfile` — Ingress on 8099 (allow `172.30.32.2`)
- `config.yaml` — manifest (`slug: rancher` must match folder)

## Conventions for this app

- Keep the wrapper **thin** — prefer upstream `entrypoint.sh` and env vars over reimplementing Rancher logic
- Bump `RANCHER_TAG` in `Dockerfile` when shipping a new upstream Rancher release
- `k3s_haos_compat` sets `CONTAINERD_SNAPSHOTTER=native` for overlay-backed HA `/data`
- Target **HAOS only** — do not add Supervised / cgroup v1 workarounds
- Do not commit bootstrap passwords

## Versioning

When shipping behavior or packaging changes:

1. Bump `version` in `config.yaml`.
2. Add a [Keep a Changelog](https://keepachangelog.com/) section to `CHANGELOG.md`.
3. Use that new section as the git commit message (see root [AGENTS.md](../AGENTS.md#app-changes-changelog-and-commits)).
