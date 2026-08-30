# HAOS Rancher

Home Assistant app repository that runs [Rancher](https://www.rancher.com/) on [Home Assistant OS](https://www.home-assistant.io/installation/).

Rancher is an open-source Kubernetes management platform. This app deploys the official `rancher/rancher` container on your Home Assistant host and exposes the UI through Home Assistant Ingress.

## Requirements

- Home Assistant OS or Supervised installation
- At least **4 GB RAM** (Rancher requirement)
- Protection mode **disabled** for this app
- Advanced Mode enabled in your Home Assistant profile

## Installation

1. Copy this repository to your Home Assistant `addons` folder, or add it as a custom repository in **Settings → Apps → App store → ⋮ → Repositories**:

   ```
   https://github.com/haos-rancher/haos-rancher
   ```

2. Go to **Settings → Apps → App store** and click **Check for updates**.
3. Install **Rancher** from the **Local apps** or repository section.
4. Open the app configuration page and **disable Protection mode**.
5. Set a bootstrap password and start the app.
6. Open the Rancher UI via **Open web UI** (Ingress).

## Repository structure

```
repository.yaml
rancher/
  config.yaml
  Dockerfile
  DOCS.md
  README.md
  CHANGELOG.md
  rootfs/
  translations/
```

## Documentation

See [rancher/DOCS.md](rancher/DOCS.md) for configuration options and troubleshooting.

## Warning

Running Rancher on Home Assistant OS is an advanced use case. Home Assistant does not officially support running arbitrary third-party containers on HAOS. Use at your own risk.
