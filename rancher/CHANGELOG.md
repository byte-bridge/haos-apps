# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.2] - 2026-08-30

### Fixed

- Protection mode check now matches bashio (`(.data // .).protected // false`) instead of defaulting to enabled when the Supervisor field is missing.

## [2.0.1] - 2026-08-30

### Fixed

- Download Caddy and jq in an Alpine build stage; `rancher/rancher` (BCI micro) has no CA bundle for `curl`, which broke the 2.0.0 image build.

## [2.0.0] - 2026-08-30

### Changed

- Run upstream `rancher/rancher` directly as the app container (`FROM rancher/rancher`) instead of a hassio-addons base wrapper that starts a nested host container.
- Replace Alpine nginx + s6 + docker-cli with a thin entrypoint, static Caddy on `:8099` for Ingress, and jq for options.
- Persist data under app `/data/rancher` (bind-mounted to `/var/lib/rancher`) instead of Docker volume `hassio_addon_rancher_data`.
- Drop `docker_api`, `host_network`, `rancher_version`, `http_port`, and `https_port` options.

### Removed

- Host `docker run` orchestration and k3s log dump via a separate container.

## [1.0.9] - 2026-08-30

### Fixed

- Re-enable minimal HAOS k3s flags (`CONTAINERD_SNAPSHOTTER=native`, `--cgroupns host`, tmpfs `/run`) behind `k3s_haos_compat` (default on) so embedded k3s can start on overlay-backed Docker volumes without the broader 1.0.2 workarounds.

## [1.0.8] - 2026-08-30

### Changed

- `reset_data` is cleared automatically after wiping the Rancher volume so a one-time reset does not repeat on every boot.

## [1.0.7] - 2026-08-30

### Fixed

- Remove leftover `/var/lib/rancher/k3s/server/db/reset-flag` before start so k3s can recover after a previous `--cluster-reset`.

## [1.0.6] - 2026-08-30

### Fixed

- Ingress nginx now sends Rancher’s layer-7 proxy headers (`X-Forwarded-Proto`, `X-Forwarded-Port`) so the container does not HTTP→HTTPS redirect behind Home Assistant TLS.

## [1.0.5] - 2026-08-30

### Changed

- Revert HAOS-specific k3s workarounds (`--cgroupns host`, tmpfs, ulimits, `CONTAINERD_SNAPSHOTTER=native`) and match the official Docker run flags again.

## [1.0.4] - 2026-08-30

### Changed

- Pin `ghcr.io/hassio-addons/base:21.0.3` ([app-base](https://github.com/hassio-addons/app-base)) and drop redundant `jq` (provided by the base image). Weekly GitHub Action keeps the pin current.

## [1.0.3] - 2026-08-30

### Changed

- Align Docker launch with the official single-node install Option E (`--no-cacerts`). Ingress already terminates TLS, so certificates are not mounted.

## [1.0.2] - 2026-08-30

### Fixed

- Start embedded k3s with Docker flags required on HAOS (cgroup namespace, tmpfs `/run`, ulimits, AppArmor/seccomp unconfined).
- Use the `native` containerd snapshotter so k3s is not overlay-on-overlay on HAOS volumes.
- Print k3s/containerd logs when the Rancher container exits.

### Added

- `reset_data` option to wipe the Rancher volume after a failed cluster init.

## [1.0.1] - 2026-08-30

### Fixed

- Stop nginx from binding host port 80 (Alpine default site) which conflicts with Home Assistant when the app uses host networking.

## [1.0.0] - 2026-08-30

### Added

- Initial release of the Rancher Home Assistant app
- Deploys official `rancher/rancher` image via Docker API
- Home Assistant Ingress integration with nginx reverse proxy
- Configurable bootstrap password, Rancher version, and server URL
- Persistent data via Docker volume `hassio_addon_rancher_data`
- Optional direct host port exposure for HTTP/HTTPS
