# Rancher App for Home Assistant

This app deploys [Rancher Manager](https://www.rancher.com/) on **Home Assistant OS** using the [single-node Docker install](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker/). That method is for **development and testing only**, not production.

It is not aimed at [Home Assistant Supervised](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md). That install method was dropped in [architecture discussion #1198](https://github.com/home-assistant/architecture/discussions/1198) (deprecated from HA 2025.6). Use **Home Assistant OS** instead.

Home Assistant Ingress is a [layer-7 proxy that terminates TLS](https://ranchermanager.docs.rancher.com/v2.15/how-to-guides/advanced-user-guides/configure-layer-7-nginx-load-balancer) in front of `rancher/rancher`. The container is started with `--no-cacerts` (Rancher Option B for a recognized CA / no default CA in the container). No PEM files are mounted.

## Requirements

From Rancher’s [installation requirements](https://ranchermanager.docs.rancher.com/v2.15/getting-started/installation-and-upgrade/installation-requirements/) **Docker** table (single-node, not production):

| Size | Max clusters | Max nodes | vCPUs | RAM |
|------|--------------|-----------|-------|-----|
| Small | 5 | 50 | 1 | 4 GB |
| Medium | 15 | 200 | 2 | 8 GB |

Also:

- Linux host, **amd64** or **aarch64** (`rancher/rancher` is multi-arch)
- Firefox or a Chromium-based browser for the UI
- Enough RAM **on the HAOS machine** after Home Assistant itself is running
- SSD storage is recommended (Rancher’s datastore is etcd inside the container)

## Warning

This app requires **Protection mode** to be disabled and grants **full hardware access** plus **Docker API** access. It is intended for advanced users who understand the security implications.

Home Assistant does not officially support running third-party containers on HAOS. Using this app may render your installation unsupported.

## Installation

1. Enable **Advanced Mode** in your Home Assistant profile.
2. Add this repository under **Settings → Apps → App store → ⋮ → Repositories**:

   ```
   https://github.com/byte-bridge/haos-apps
   ```

3. Click **Check for updates** in the app store.
4. Install **Rancher**.
5. On the app configuration page, turn **Protection mode** off.
6. Configure options (see below) and start the app.

## First login

1. Open the Rancher UI via **Open web UI** in the app panel.
2. Log in with:
   - **Username:** `admin`
   - **Password:** the bootstrap password you configured, or retrieve it from the app logs if left empty.

If you did not set a bootstrap password, Rancher generates one randomly. Check the app logs for:

```
Bootstrap Password:
```

You can also retrieve it from inside the running Rancher container:

```bash
docker exec hassio-rancher kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
```

## Configuration options

### Option: `log_level`

Controls add-on log verbosity. Default: `info`.

### Option: `rancher_version`

Docker image tag for Rancher. Default: `stable`.

Examples: `stable`, `v2.10.3`, `latest`

### Option: `bootstrap_password`

Initial password for the `admin` user. Strongly recommended. If empty, Rancher generates a random password on first start.

### Option: `server_url`

External URL where Rancher is accessed. Set this if you use Ingress or a reverse proxy and Rancher reports an incorrect URL.

Example: `https://homeassistant.local:8123`

For Ingress, you may need to set this to your Home Assistant URL. Rancher uses it for agent registration and redirects.

### Option: `http_port` / `https_port`

Local host ports used to publish the Rancher container (bound to `127.0.0.1` only). Defaults: `18080` / `18443`.

Change these only if they conflict with another service on your host.

### Option: `reset_data`

When `true`, the app deletes Docker volume `hassio_addon_rancher_data` before starting, then automatically sets this option back to `false`. Use this after a failed k3s start (`k3s exited with: exit status 2`). If auto-clear fails (check the app log), turn it off manually or every restart will wipe Rancher again.

## Network access

By default, Rancher is available through **Home Assistant Ingress** only. To expose Rancher directly on your LAN, enable the optional host ports in the app **Network** section:

| Port | Description        |
|------|--------------------|
| 80   | Rancher HTTP       |
| 443  | Rancher HTTPS      |

When enabling direct access, map them to non-conflicting host ports (for example `8080` and `8443`). Official docs use the same remap when Rancher and an ingress controller share a node.

## TLS / certificates

No custom certificates are required. [Home Assistant Ingress](https://developers.home-assistant.io/docs/apps/presentation#ingress) terminates TLS, same role as Rancher’s [layer-7 NGINX load balancer](https://ranchermanager.docs.rancher.com/v2.15/how-to-guides/advanced-user-guides/configure-layer-7-nginx-load-balancer).

This app’s nginx:

- Proxies to `rancher/rancher` on HTTP (container port 80)
- Sends `Host`, `X-Forwarded-Proto`, `X-Forwarded-Port`, `X-Forwarded-For`
- Supports WebSockets (`Upgrade` / `Connection`)
- Sets `X-Forwarded-Proto: https` by default so Rancher **does not** redirect HTTP→HTTPS (HA already used HTTPS)

The Rancher container is started with `--no-cacerts`. Do not enable Let’s Encrypt (`--acme-domain`): port 80 is not published to the internet.

## Data persistence

Rancher data is stored in the Docker volume `hassio_addon_rancher_data`, mounted at `/var/lib/rancher` as described in [persistent data for Docker installs](https://ranchermanager.docs.rancher.com/reference-guides/single-node-rancher-in-docker/advanced-options).

## Troubleshooting

### App does not appear in the store

- Check **Settings → System → Logs → Supervisor** for `config.yaml` validation errors.
- Hard-refresh the browser (Ctrl+F5).

### Rancher container fails to start

- Confirm Protection mode is disabled.
- Ensure the host has at least 4 GB RAM available.
- Check app logs for Docker pull or permission errors.

### `Managed etcd cluster membership was previously reset`

k3s left `/var/lib/rancher/k3s/server/db/reset-flag` after a failed start. From 1.0.7 the app deletes that file before each start.

If it still fails:

1. Update to **1.0.7+** and start again (do **not** leave **Reset Rancher data** on unless you want a wipe).
2. If etcd is still corrupt, enable **Reset Rancher data** once, start, then turn it off.

### `k3s exited with: exit status 2`

Embedded k3s (inside `rancher/rancher`) failed to start. Try:

1. Enable **Reset Rancher data** once, start the app, wait several minutes, then disable it.
2. Ensure the host has at least 4 GB RAM free.
3. Check app logs after the container stops (includes recent Rancher and k3s logs).

If it still fails, Rancher’s single-node Docker install is not officially supported on all HAOS setups.

### Ingress shows a blank page or connection errors

- Wait several minutes on first start; Rancher can take time to initialize.
- Verify the watchdog URL responds in the app **Info** tab.
- Set `server_url` to your Home Assistant **HTTPS** URL if redirects or agent registration fail (`X-Forwarded-Proto` must be `https`).

### Retrieve bootstrap password

See [First login](#first-login) above.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

This app repository is provided as-is. Rancher is licensed separately; see [Rancher licensing](https://www.rancher.com/pricing).
