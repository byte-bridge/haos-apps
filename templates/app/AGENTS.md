# App scaffold — agent instructions

This folder is the **template** for new apps. Copy it to a new top-level slug; do not edit it in place as a live app.

```bash
cp -r templates/app <slug>
mv <slug>/config.yaml.example <slug>/config.yaml
```

Then replace this file with app-specific agent instructions (pattern, key files, security flags, upstream links). See `rancher/AGENTS.md` for a filled example and the root [AGENTS.md](../../AGENTS.md) for repo conventions.

## Default pattern (native)

This scaffold is a **native** in-container service (s6 + bashio), similar in packaging to [home-assistant/apps-example](https://github.com/home-assistant/apps-example). It is not a host Docker wrapper.

If the new app needs a privileged upstream container (like Rancher), follow `rancher/` — `FROM` the upstream image with a thin HA entrypoint — instead of this native s6 pattern.

## Versioning

When shipping changes: bump `version` in `config.yaml`, add a section to `CHANGELOG.md`, and use that section as the git commit message (see root [AGENTS.md](../../AGENTS.md#app-changes-changelog-and-commits)).
