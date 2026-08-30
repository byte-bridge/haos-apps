# Adding a new app

This repository follows the [Home Assistant app structure](https://developers.home-assistant.io/docs/apps/configuration). Each app is a top-level folder sibling to `repository.yaml`.

## Quick start

```bash
cp -r templates/app my-app
mv my-app/config.yaml.example my-app/config.yaml
```

Then edit the files listed below.

## Checklist

### 1. `config.yaml` (required)

Update at minimum:

- `name` — display name in the app store
- `slug` — folder name, URI-safe, unique in this repo
- `version` — semver string
- `description` — one-line summary
- `url` — link to this app's docs in the repo
- `arch` — supported architectures (`aarch64`, `amd64`)

See [app configuration docs](https://developers.home-assistant.io/docs/apps/configuration) for all options.

### 2. `Dockerfile` (required unless using `image:`)

Base image options:

- `ghcr.io/hassio-addons/base` — community base with s6-overlay and bashio (recommended for scripted apps)
- `ghcr.io/home-assistant/{arch}-base` — official Home Assistant base
- Upstream image via `image:` + `legacy: true` in `config.yaml`

Include `io.hass.*` labels when building locally without the HA builder.

### 3. `rootfs/` (if using s6-overlay)

Standard layout:

```
rootfs/
  etc/
    cont-init.d/       # Runs once at container start
    services.d/
      myservice/
        run            # Main process (use exec)
        finish         # Cleanup on stop (optional)
```

Scripts must use `#!/usr/bin/with-contenv bashio` and LF line endings.

### 4. Documentation (required for publication)

- `README.md` — short intro shown in the app store
- `DOCS.md` — full user documentation
- `CHANGELOG.md` — version history
- `translations/en.yaml` — UI label translations for config options

### 5. Assets

- `icon.png` — 128×128 square
- `logo.png` — ~250×100 banner

### 6. Register the app

- Add a row to the apps table in the root `README.md`
- CI builds all app folders automatically via `--all`

## App patterns in this repo

| Pattern | Example | When to use |
|---------|---------|-------------|
| **Wrapper** | `rancher/` | Run an upstream Docker image via host Docker API |
| **Native** | `templates/app/` | Install a binary or run a service directly in the app container |
| **Ingress proxy** | `rancher/` | nginx on port 8099 proxying to the service |

## Security considerations

Apps that need host access typically require:

- `advanced: true`
- Protection mode disabled by the user
- `docker_api`, `full_access`, or specific `privileged` capabilities

Document all security requirements in the app's `DOCS.md`. See the [security rating docs](https://developers.home-assistant.io/docs/apps/presentation#security).

## Testing locally

1. Copy the app folder to `/addons/<slug>` on your HA instance.
2. **Settings → Apps → App store → Check for updates**
3. If the app doesn't appear, check **Settings → System → Logs → Supervisor** for `config.yaml` validation errors.

## References

- [App tutorial](https://developers.home-assistant.io/docs/apps/tutorial)
- [App configuration](https://developers.home-assistant.io/docs/apps/configuration)
- [Ingress](https://developers.home-assistant.io/docs/apps/presentation#ingress)
- [Example repository](https://github.com/home-assistant/addons-example)
