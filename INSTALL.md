# Local install (no git repository)

1. Copy the `rancher` folder to your Home Assistant `addons` directory:
   - Samba share: `addons/rancher`
   - SSH: `/addons/rancher`
2. In Home Assistant go to **Settings → Apps → App store**.
3. Click **Check for updates** (top-right menu).
4. Install **Rancher** from the **Local apps** section.

# Git repository install

1. Add this repository URL under **Settings → Apps → App store → ⋮ → Repositories**:

   ```
   https://github.com/byte-bridge/haos-rancher
   ```

2. Click **Check for updates** and install **Rancher**.

# After install

1. Enable **Advanced Mode** in your profile.
2. Open the Rancher app configuration.
3. Disable **Protection mode**.
4. Set a **Bootstrap password**.
5. Start the app and open the web UI via Ingress.

See [rancher/DOCS.md](rancher/DOCS.md) for full documentation.
