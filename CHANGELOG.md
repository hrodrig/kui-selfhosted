# Changelog

All notable changes to **kui-selfhosted** (deployment manifests) are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.8] - 2026-06-23

### Changed

- **Chart version** — bump `0.1.3` → `0.1.4`, `appVersion` v0.4.4 → v0.5.0.
- **Helm values** — kiko.image.tag v0.4.4 → v0.5.0.
- **Compose defaults** — `KIKO_VERSION=v0.5.0` in `.env.example` and Compose files.
- **README** — update Helm example tag to v0.5.0.

## [0.1.7] - 2026-06-21

### Changed

- **Chart version** — bump `0.1.2` → `0.1.3`, `appVersion` v0.4.3 → v0.4.4.
- **Helm values** — kiko.image.tag v0.4.3 → v0.4.4.
- **Compose defaults** — `KIKO_VERSION=v0.4.4`.
- **README** — update helm example tags.

## [0.1.7] - 2026-06-21

### Changed

- **Helm chart** — bump `version` 0.1.0 → 0.1.1, `appVersion` v0.1.0 → v0.4.0.
- **Helm values** — kiko.image.tag v0.1.0 → v0.4.0.
- **README** — fix ingress relative path, update stale image tag examples.

## [0.1.5] - 2026-06-21

### Changed

- **Traefik image** — bump `v3.6.17` → `v3.7.5`.

## [0.1.4] - 2026-06-20

### Fixed

- **Traefik routing** — use separate `KIKO_HOSTNAME` and `KUI_HOSTNAME`
  for kiko and kui subdomains instead of a single shared hostname.

## [0.1.3] - 2026-06-20

### Changed

- **`.env.example`** — add `STACK_HOSTNAME`, `ACME_EMAIL`, `KIKO_VISITOR_SALT`
  entries required by the Traefik compose stack. Document both minimal and
  Traefik compose usage in the header.

## [0.1.2] - 2026-06-20

### Added

- **Traefik compose stack** — production `docker-compose/traefik/` with TLS termination
  (Let's Encrypt) for kiko + kui.
- **`compose-stack.sh` helper** — start/stop individual services without restarting Traefik,
  avoiding unnecessary TLS cert requests.
- **gghstats badge** in README (clone metrics).

### Changed

- **Default image versions** — `KIKO_VERSION` → v0.4.0, `KUI_VERSION` → v0.3.1
  in `.env.example`.

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
