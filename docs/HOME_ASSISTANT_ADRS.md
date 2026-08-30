# Home Assistant architecture ADRs

Relevant [Architecture Decision Records](https://github.com/home-assistant/architecture/tree/master/adr) for this repository.

Full index: https://github.com/home-assistant/architecture/tree/master/adr

## Supported install methods (ADR-0012)

[ADR-0012](https://github.com/home-assistant/architecture/blob/master/adr/0012-define-supported-installation-method.md) defines what “supported” means: tested, documented, and maintained by the Home Assistant team. Unofficial methods may work but are not guaranteed.

This **haos-apps** repo ships **Supervisor apps** (formerly add-ons). Apps require the Supervisor, which limits where they run.

## Which ADRs apply to this repo

| ADR | Install method | Status | Apps / Supervisor? | Relevance |
|-----|----------------|--------|--------------------|-----------|
| [0015](https://github.com/home-assistant/architecture/blob/master/adr/0015-home-assistant-os.md) | **Home Assistant OS** | Accepted | Yes | **Primary target.** Recommended HA install. |
| [0014](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md) | Home Assistant Supervised | **Reverted** | Was yes | **Do not target.** Use HAOS instead. |
| [0013](https://github.com/home-assistant/architecture/blob/master/adr/0013-home-assistant-container.md) | Home Assistant Container | Accepted | **No** | Core only — no App store, no apps from this repo. |
| [0016](https://github.com/home-assistant/architecture/blob/master/adr/0016-home-assistant-core.md) | Home Assistant Core | Accepted | No | Python venv install — not applicable. |

## Home Assistant OS (ADR-0015) — our target

[ADR-0015](https://github.com/home-assistant/architecture/blob/master/adr/0015-home-assistant-os.md):

- Full HA experience with Supervisor, backups, and OS updates via UI
- Runs on dedicated boards/VMs (Pi 64-bit, HA Green/Yellow, ODROID, x86-64, etc.)
- Low expertise for day-to-day maintenance

When developing or documenting apps here, assume **HAOS + Supervisor**, not a user-managed Linux host.

## Home Assistant Supervised (ADR-0014) — do not use

[ADR-0014](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md) is **reverted** by [architecture discussion #1198](https://github.com/home-assistant/architecture/discussions/1198) (approved May 2025).

### What discussion #1198 decided

Home Assistant **dropped Supervised as an officially supported install method**. It may still run on a user-managed Debian host, but the project no longer documents, recommends, or supports it.

| Topic | Detail |
|-------|--------|
| **Decision** | Approved by the core team; [ADR-0014 reverted](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md) |
| **Timeline** | Deprecation began with Home Assistant **2025.6** (six-month period) |
| **Migration** | Users should move to **HAOS** (full experience) or **Container** (Core only, no apps) |
| **Why** | High complexity, fragile on OS/Docker updates, ~3.3% adoption vs ~77% HAOS |
| **Still possible?** | Yes, but unsupported — community guides only, no pre-release testing |

Frenck’s proposal ([discussion #1198](https://github.com/home-assistant/architecture/discussions/1198)) explicitly states this does **not** remove the ability to run that way; it removes official recommendation, documentation, and support.

### Implications for haos-apps

- **Document and test on HAOS only** — not Supervised on Debian/Ubuntu/Armbian.
- **Do not** copy Supervised host requirements (cgroup v1, overlayfs2, NetworkManager, dedicated Debian) into HAOS app code.
- **Do not** list “Home Assistant Supervised” alongside HAOS in install docs.
- Supervised’s old addon ecosystem is not a supported target for new development in this repo.

ADR-0014 previously required a dedicated Debian host with Docker CE, cgroup v1, overlayfs2, NetworkManager, etc. Those rules applied to **Supervised hosts**, not HAOS.

Do not:

- Document or test against Supervised as an official path
- Copy Supervised host Docker/cgroup requirements into HAOS app code
- Tell users to install Rancher via a manual Debian + Docker setup as part of this repo

## Home Assistant Container (ADR-0013) — out of scope

[ADR-0013](https://github.com/home-assistant/architecture/blob/master/adr/0013-home-assistant-container.md) runs **Core in Docker only**. There is no Supervisor panel and **no apps**.

Users on Container cannot install from this repository. Do not document Container as a supported install path for haos-apps.

## Advanced / unsupported use on HAOS

Apps like **Rancher** that use `docker_api`, `full_access`, and Protection mode off go beyond what Home Assistant documents for HAOS. They may work for advanced users but can render the installation **unsupported**.

Always document that clearly in each app’s `DOCS.md`.

## Other ADRs

Most other ADRs in the index cover Core integrations, Python versions, translations, etc. They rarely affect app packaging. When in doubt, search the [adr/](https://github.com/home-assistant/architecture/tree/master/adr) folder for keywords.
