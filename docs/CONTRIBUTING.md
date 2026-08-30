# Contributing

## Prerequisites

- A Home Assistant OS or Supervised instance for testing
- Familiarity with [Home Assistant app development](https://developers.home-assistant.io/docs/apps/)

## Workflow

1. Fork the repository.
2. Create a branch for your app or fix.
3. Follow [ADDING_AN_APP.md](ADDING_AN_APP.md) for new apps.
4. Test on a real HA instance before opening a PR.
5. Update `CHANGELOG.md` in the affected app folder.

## Commit messages

Use clear, imperative subjects:

```
Add portainer app
Fix rancher ingress proxy headers
Update rancher to pass CATTLE_SYSTEM_CATALOG option
```

## Pull requests

Include in the PR description:

- Which app(s) changed
- How you tested (HA version, architecture)
- Any new security/permission requirements

## CI

GitHub Actions builds all apps on push/PR using the [Home Assistant builder](https://github.com/home-assistant/builder). Builds must pass before merge.
