# Installation

## Git repository (recommended)

1. Add this repository under **Settings → Apps → App store → ⋮ → Repositories**:

   ```
   https://github.com/byte-bridge/haos-apps
   ```

2. Click **Check for updates**.
3. Install the app you want from the store.

## Local install (development)

1. Clone this repository into your Home Assistant `addons` directory, or copy a single app folder:

   - Samba share: `addons/`
   - SSH: `/addons/`

   For a single app during development, copy only that app's folder (e.g. `rancher/`) into `addons/`.

2. Go to **Settings → Apps → App store** and click **Check for updates**.
3. Install from the **Local apps** section.

## Per-app setup

Each app has its own requirements. Check the app's `DOCS.md` before starting.

### Rancher

1. Enable **Advanced Mode** in your profile.
2. Install the **Rancher** app.
3. Disable **Protection mode** on the app configuration page.
4. Set a **Bootstrap password**.
5. Start the app and open the web UI via Ingress.

See [rancher/DOCS.md](../rancher/DOCS.md) for full Rancher documentation.
