# Contributing

## Prerequisites

- A Home Assistant OS or Supervised instance for testing
- Familiarity with [Home Assistant app development](https://developers.home-assistant.io/docs/apps/) and the official [apps-example](https://github.com/home-assistant/apps-example) repository (layout, `config.yaml`, s6 `rootfs`, CI)

## Workflow

1. Fork the repository.
2. Create a branch for your app or fix.
3. Follow [ADDING_AN_APP.md](ADDING_AN_APP.md) for new apps.
4. Test on a real HA instance before opening a PR.
5. Bump `version` in the app’s `config.yaml` and add a section to that app’s `CHANGELOG.md`.

## Commit messages

**App changes:** the commit message is the new `CHANGELOG.md` entry. Write the changelog first, then commit using that text (see [AGENTS.md](../AGENTS.md#app-changes-changelog-and-commits)).

```
rancher 1.0.8

### Changed

- `reset_data` is cleared automatically after wiping the Rancher volume so a one-time reset does not repeat on every boot.
```

**Repo-wide changes** (CI, root docs, `repository.yaml`): use a clear imperative subject, for example `Sync app-base to 21.0.4` or `Document HAOS-only target in CONTRIBUTING`.

## Pull requests

Include in the PR description:

- Which app(s) changed
- How you tested (HA version, architecture)
- Any new security/permission requirements

## CI

GitHub Actions builds all apps on push/PR using the [Home Assistant builder](https://github.com/home-assistant/builder). Builds must pass before merge.

The **Sync hassio-addons/app-base** workflow runs weekly (and on demand). It reads the latest [app-base](https://github.com/hassio-addons/app-base) release and opens a PR that bumps `ARG BUILD_FROM=ghcr.io/hassio-addons/base:…` in every Dockerfile.
