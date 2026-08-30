# Rancher

[Rancher](https://www.rancher.com/) is an open-source Kubernetes management platform. This Home Assistant app runs the official `rancher/rancher` Docker image on your Home Assistant host and exposes the web UI through Home Assistant Ingress.

## Quick start

1. Install the app from this repository.
2. Disable **Protection mode** on the app configuration page.
3. Set a **Bootstrap password** (recommended).
4. Start the app and click **Open web UI**.
5. Log in with username `admin` and your bootstrap password.

## Requirements

- **Home Assistant OS** (Supervised is not a supported HA install method)
- [Rancher Docker install](https://ranchermanager.docs.rancher.com/v2.15/getting-started/installation-and-upgrade/installation-requirements/) hardware: **1 vCPU / 4 GB RAM** (small) or **2 vCPU / 8 GB RAM** (medium). Docker install is for development/testing only.
- Protection mode disabled
- Advanced Mode enabled in your profile

## Configuration

See [DOCS.md](DOCS.md) for all options.

## Support

- [Rancher documentation](https://ranchermanager.docs.rancher.com/)
- [Home Assistant Apps documentation](https://developers.home-assistant.io/docs/apps/)
