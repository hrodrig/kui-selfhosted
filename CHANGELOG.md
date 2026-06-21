# Changelog

All notable changes to **kui-selfhosted** (deployment manifests) are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.1] - 2026-06-20

### Added

- **kui probes** — liveness `GET /api/v1/healthz` and readiness `GET /api/v1/readyz`
  in Helm chart and MicroK8s manifest (kui now exposes both endpoints).

### Changed

- **kui image tag** updated to `v0.3.1` in Helm values and MicroK8s manifest.
- **kiko PVC size** increased from 2Gi to 24Gi.

## [0.1.0] - 2026-06-20

### Added

- Initial repository: Compose minimal (kiko + kui), Helm chart, MicroK8s raw manifests.
- Shared secrets: `KIKO_API_KEY`, `KUI_ADMIN_PASSWORD`.
- kiko probes: liveness `GET /api/v1/healthz`, readiness `GET /api/v1/readyz`.
- SQLite PVC/bind mounts for both services.
