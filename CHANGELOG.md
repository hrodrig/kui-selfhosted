# Changelog

All notable changes to **kui-selfhosted** (deployment manifests) are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] - 2026-06-20

### Added

- Initial repository: Compose minimal (kiko + kui), Helm chart, MicroK8s raw manifests.
- Shared secrets: `KIKO_API_KEY`, `KUI_ADMIN_PASSWORD`.
- kiko probes: liveness `GET /api/v1/healthz`, readiness `GET /api/v1/readyz`.
- SQLite PVC/bind mounts for both services.
