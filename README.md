# HAOS Apps

Home Assistant [app repository](https://developers.home-assistant.io/docs/apps/) for running third-party services on [Home Assistant OS](https://www.home-assistant.io/installation/).

Each app lives in its own top-level folder with a `config.yaml`. Home Assistant discovers apps by scanning this repository for those folders.

## Apps

| App | Description | Docs |
|-----|-------------|------|
| [rancher](rancher/) | Rancher Kubernetes management platform | [DOCS](rancher/DOCS.md) |

## Install

Add this repository in **Settings → Apps → App store → ⋮ → Repositories**:

```
https://github.com/byte-bridge/haos-apps
```

Then click **Check for updates** and install the app you want.

See [docs/INSTALL.md](docs/INSTALL.md) for local install and per-app setup notes.

## Repository layout

```
repository.yaml          # Required — registers this repo with Home Assistant
README.md
AGENTS.md                # Repo-wide agent instructions
rancher/                 # One folder per app (slug matches config.yaml)
  AGENTS.md              # App-specific agent instructions (nested)
  config.yaml
  Dockerfile
  DOCS.md
  rootfs/
templates/app/           # Scaffold for new apps (includes AGENTS.md)
docs/                    # Shared documentation
.cursor/rules/           # Cursor project rules (.mdc)
```

## Adding a new app

1. Copy `templates/app/` to a new top-level folder (e.g. `my-app/`).
2. Rename `config.yaml.example` to `config.yaml`.
3. Update `config.yaml` — especially `name`, `slug`, `version`, and `description`.
4. Fill in `AGENTS.md` for that app (runtime pattern, key files, security).
5. Implement `Dockerfile` and `rootfs/` for your service.
6. Add the app to the table in this README.
7. Open a PR.

See [docs/ADDING_AN_APP.md](docs/ADDING_AN_APP.md) for the full checklist.

## Development

- [Home Assistant Apps docs](https://developers.home-assistant.io/docs/apps/)
- [Official apps-example](https://github.com/home-assistant/apps-example) — packaging blueprint (layout, files, CI)
- [Home Assistant ADRs](docs/HOME_ASSISTANT_ADRS.md) — install methods (HAOS vs Supervised vs Container)
- [Contributing](docs/CONTRIBUTING.md)
- [Agent instructions](AGENTS.md) — root; per-app files under `<slug>/AGENTS.md` (e.g. [rancher](rancher/AGENTS.md))

## Warning

Apps in this repository may require **Protection mode** to be disabled and grant elevated host access. Home Assistant does not officially support arbitrary third-party containers on HAOS. Use at your own risk.
