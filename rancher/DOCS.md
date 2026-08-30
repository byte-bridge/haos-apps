# Rancher App for Home Assistant

This app deploys [Rancher Manager](https://www.rancher.com/) on Home Assistant OS using the official [`rancher/rancher`](https://hub.docker.com/r/rancher/rancher) container image.

## Warning

This app requires **Protection mode** to be disabled and grants **full hardware access** plus **Docker API** access. It is intended for advanced users who understand the security implications.

Home Assistant does not officially support running third-party containers on HAOS. Using this app may render your installation unsupported.

## Installation

1. Enable **Advanced Mode** in your Home Assistant profile.
2. Add this repository under **Settings → Apps → App store → ⋮ → Repositories**:

   ```
   https://github.com/byte-bridge/haos-rancher
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

## Network access

By default, Rancher is available through **Home Assistant Ingress** only. To expose Rancher directly on your LAN, enable the optional host ports in the app **Network** section:

| Port | Description        |
|------|--------------------|
| 80   | Rancher HTTP       |
| 443  | Rancher HTTPS      |

When enabling direct access, map them to non-conflicting host ports (for example `8080` and `8443`).

## Data persistence

Rancher data is stored in the Docker volume `hassio_addon_rancher_data` on your Home Assistant host. This survives app restarts and upgrades.

## Troubleshooting

### App does not appear in the store

- Check **Settings → System → Logs → Supervisor** for `config.yaml` validation errors.
- Hard-refresh the browser (Ctrl+F5).

### Rancher container fails to start

- Confirm Protection mode is disabled.
- Ensure the host has at least 4 GB RAM available.
- Check app logs for Docker pull or permission errors.

### Ingress shows a blank page or connection errors

- Wait several minutes on first start; Rancher can take time to initialize.
- Verify the watchdog URL responds in the app **Info** tab.
- Set `server_url` to your Home Assistant external URL if redirects fail.

### Retrieve bootstrap password

See [First login](#first-login) above.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

This app repository is provided as-is. Rancher is licensed separately; see [Rancher licensing](https://www.rancher.com/pricing).
