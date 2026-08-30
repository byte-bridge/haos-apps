# Rancher App for Home Assistant

This app runs the upstream [`rancher/rancher`](https://hub.docker.com/r/rancher/rancher) image on **Home Assistant OS** with a thin Ingress wrapper. It follows Rancher’s [single-node Docker install](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker/) (dev/test only, not production).

The app container **is** `rancher/rancher` (see [`package/`](https://github.com/rancher/rancher/tree/main/package) upstream). A small Home Assistant entrypoint bind-mounts `/data/rancher` and starts [Caddy](https://caddyserver.com/) on port **8099** for Ingress. There is no nested `docker run` and no hassio-addons base image.

Home Assistant Ingress [terminates TLS](https://ranchermanager.docs.rancher.com/v2.15/how-to-guides/advanced-user-guides/configure-layer-7-nginx-load-balancer) in front of Rancher. The container runs with `--no-cacerts` (Option E). No PEM files are mounted.

## Requirements

From Rancher’s [installation requirements](https://ranchermanager.docs.rancher.com/v2.15/getting-started/installation-and-upgrade/installation-requirements/) **Docker** table (single-node, not production):

| Size | Max clusters | Max nodes | vCPUs | RAM |
|------|--------------|-----------|-------|-----|
| Small | 5 | 50 | 1 | 4 GB |
| Medium | 15 | 200 | 2 | 8 GB |

Also:

- **Home Assistant OS**, amd64 or aarch64
- At least **4 GB RAM** free after Home Assistant
- SSD-backed storage recommended (embedded etcd)

## Warning

This app requires **Protection mode** to be disabled and grants **full hardware access**. It runs a privileged Rancher/k3s workload inside the app container. Advanced users only.

Home Assistant does not officially support Rancher on HAOS. Using this app may render your installation unsupported.

## Installation

1. Enable **Advanced Mode** in your Home Assistant profile.
2. Add this repository under **Settings → Apps → App store → ⋮ → Repositories**:

   ```
   https://github.com/byte-bridge/haos-apps
   ```

3. Click **Check for updates** in the app store.
4. Install **Rancher**.
5. Turn **Protection mode** off on the app **Info** page (not Configuration), wait for the switch to save, then start the app. Re-check after each app update — Supervisor defaults protection to on for new installs/rebuilds.
6. Set a **bootstrap password**, then start the app.

First boot can take **5–10 minutes**.

## Upgrading from 1.x (Docker wrapper)

Version **2.0.0** replaces the old design (hassio-addons base + host `docker run`) with a direct `FROM rancher/rancher` container.

1. Update to **2.0.0** and rebuild/reinstall the app.
2. Enable **Reset Rancher data** once and start (old data lived in Docker volume `hassio_addon_rancher_data`; new data is under app `/data/rancher`).
3. Reconfigure bootstrap password and `server_url` if needed.

There is no automatic migration from the old host volume.

## First login

1. Open **Open web UI** in the app panel.
2. Log in with username **`admin`** and your bootstrap password.

If bootstrap password was left empty, check app logs for `Bootstrap Password:` or run from an HAOS shell (container name varies):

```bash
docker exec "$(docker ps --filter name=_rancher --format '{{.Names}}' | head -1)" \
  kubectl get secret --namespace cattle-system bootstrap-secret \
  -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
```

## Configuration options

### Option: `bootstrap_password`

Initial password for the `admin` user. Strongly recommended.

### Option: `server_url`

External URL Rancher should advertise (for example your Home Assistant HTTPS URL). Helps with redirects and agent registration behind Ingress.

### Option: `reset_data`

When `true`, wipes `/data/rancher` on the next start, then automatically sets this back to `false`. Use after a failed k3s init.

### Option: `k3s_haos_compat`

When `true` (default), sets `CONTAINERD_SNAPSHOTTER=native` so embedded k3s can run on HAOS overlay-backed storage ([k3s#4769](https://github.com/k3s-io/k3s/issues/4769)). Upstream [`entrypoint.sh`](https://github.com/rancher/rancher/blob/main/package/entrypoint.sh) handles cgroup v2 inside the container. Turn off only when debugging.

After changing this option, use **Reset Rancher data** once on a clean start.

### Rancher version

Pinned by `RANCHER_TAG` in the app `Dockerfile` (default `stable`). Bumping the upstream tag ships with a new app release.

## Network access

- **Ingress (default):** port **8099** inside the app container (Caddy → Rancher on `127.0.0.1:80`).
- **Optional LAN access:** enable **80/tcp** and **443/tcp** in the app **Network** tab and map to free host ports (for example `8080` / `8443`).

## TLS / certificates

No custom certificates. Caddy sends `X-Forwarded-Proto: https` and `X-Forwarded-Port: 443` so Rancher does not HTTP→HTTPS redirect behind Home Assistant TLS. See Rancher’s [layer-7 nginx guide](https://ranchermanager.docs.rancher.com/v2.15/how-to-guides/advanced-user-guides/configure-layer-7-nginx-load-balancer).

## Data persistence

Rancher state is stored under **`/data/rancher`** in the app container (Supervisor persistent `/data`), bind-mounted to `/var/lib/rancher`.

## Troubleshooting

### App does not appear in the store

- Check **Settings → System → Logs → Supervisor** for `config.yaml` errors.
- Hard-refresh the browser (Ctrl+F5).

Upstream [`entrypoint.sh`](https://github.com/rancher/rancher/blob/main/package/entrypoint.sh) normally configures cgroup v2 inside the container. On HAOS, Supervisor mounts `/sys/fs/cgroup` read-only, so this app uses a thin patched entrypoint that skips that step when writes fail.

### `mkdir: cannot create directory '/sys/fs/cgroup/init': Read-only file system`

Expected on HAOS before **2.0.3**. Update to 2.0.3+ (patched entrypoint). If it persists, confirm Protection mode is off and restart after the update rebuild completes.

### Protection mode error after disabling the toggle

- Use the **Info** tab for the Protection mode switch (not Configuration).
- After an update/rebuild, Supervisor may reset protection to **on** — turn it off again.
- Wait for the switch to save (no page reload mid-toggle), then restart the app.
- In the app log, confirm you see `Supervisor reports protection mode: false` before Rancher starts.

### `k3s exited with: exit status 2`

Log lines like `very short watch` and `watcher channel closed` mean embedded k3s crashed during bootstrap.

1. Stay on **2.0.0+** with **HAOS k3s compatibility** enabled.
2. **Reset Rancher data** once, start, wait several minutes.
3. Ensure **4 GB+ RAM** free.
4. Check app logs for `overlayfs` or `snapshotter cannot be enabled`.

### Ingress blank page or redirect loop

- Wait for first-time initialization.
- Set **`server_url`** to your Home Assistant HTTPS URL.

### `Managed etcd cluster membership was previously reset`

The entrypoint clears `/var/lib/rancher/k3s/server/db/reset-flag` before each start. If etcd is still corrupt, use **Reset Rancher data** once.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

This app repository is provided as-is. Rancher is licensed separately; see [Rancher licensing](https://www.rancher.com/pricing).
