# Adding a new app

This repository follows the [Home Assistant app structure](https://developers.home-assistant.io/docs/apps/configuration). Each app is a top-level folder sibling to `repository.yaml`.

The official blueprint is [home-assistant/apps-example](https://github.com/home-assistant/apps-example). Match its file set and repo layout. Do not copy its runtime: the example app runs a small program in the app container. Wrappers like `rancher/` start an upstream image via the host Docker API instead.

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

- `ghcr.io/hassio-addons/base` — community base with s6-overlay and bashio (recommended for scripted apps). Pin a version tag; CI syncs it from https://github.com/hassio-addons/app-base/releases
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

- `AGENTS.md` — agent instructions for this app (from the template; fill in pattern and key files)
- `README.md` — short intro shown in the app store
- `DOCS.md` — full user documentation
- `CHANGELOG.md` — version history ([Keep a Changelog](https://keepachangelog.com/)); the new section is also the git commit message when you ship the change
- `translations/en.yaml` — UI label translations for config options

### 5. Assets

- `icon.png` — 128×128 square
- `logo.png` — ~250×100 banner

### 6. Register the app

- Add a row to the apps table in the root `README.md`
- Add a row under **Existing apps** in root `AGENTS.md`
- CI builds all app folders automatically via `--all`

## App patterns in this repo

| Pattern | Example | When to use |
|---------|---------|-------------|
| **Upstream + thin HA layer** | `rancher/` | `FROM` an upstream image; add entrypoint, Ingress proxy, options |
| **Native** | `templates/app/` | s6 + bashio service inside hassio-addons base |

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
- [apps-example](https://github.com/home-assistant/apps-example) — official packaging blueprint
- [app-base](https://github.com/hassio-addons/app-base) — community Alpine + s6 + bashio image
