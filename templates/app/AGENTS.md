# App scaffold — agent instructions

This folder is the **template** for new apps. Copy it to a new top-level slug; do not edit it in place as a live app.

```bash
cp -r templates/app <slug>
mv <slug>/config.yaml.example <slug>/config.yaml
```

Then replace this file with app-specific agent instructions (pattern, key files, security flags, upstream links). See `rancher/AGENTS.md` for a filled example and the root [AGENTS.md](../../AGENTS.md) for repo conventions.

## Default pattern (native)

This scaffold is a **native** in-container service (s6 + bashio), similar in packaging to [home-assistant/apps-example](https://github.com/home-assistant/apps-example). It is not a host Docker wrapper.

If the new app needs `docker_api` / privileged host containers, follow `rancher/` instead of this runtime pattern, and document Protection mode and unsupported-HAOS warnings in `DOCS.md`.
