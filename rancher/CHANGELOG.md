# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
