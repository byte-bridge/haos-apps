# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
