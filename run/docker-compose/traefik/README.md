# Traefik + TLS (production-style)

← [Back to run/README](../../README.md).

**Traefik** terminates HTTPS (Let's Encrypt) and routes to **kiko** (tracking) and **kui** (dashboard) on the **`kui_edge`** Docker network. No host ports are published for kiko or kui; only **80** and **443** for Traefik.

Compose **project** `kui-edge` (containers `kui-edge-traefik-1`, `kui-edge-kiko-1`, `kui-edge-kui-1`).

**Traefik image:** pinned in [`docker-compose.yml`](docker-compose.yml) (currently **`traefik:v3.6.17`**, 3.6.x line). Stay on **≥ v3.6.14** for published security fixes.

From the **repository root**:

```bash
export STACK_HOST_DATA=/home/kui/stack-data
mkdir -p "$STACK_HOST_DATA/kiko-data" "$STACK_HOST_DATA/kui-data"
cp run/common/.env.example "${STACK_HOST_DATA}/.env"
# Set STACK_HOSTNAME, ACME_EMAIL, KIKO_VISITOR_SALT, KIKO_API_KEY,
# KUI_ADMIN_PASSWORD, and STACK_HOST_DATA (same absolute path)

docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml up -d
```

Ensure DNS for `STACK_HOSTNAME` points to this host and **80/443** are reachable for ACME.

**Routing:**

| Path | Service |
|------|---------|
| `/hit`, `/hit.gif`, `/kiko.js`, `/api/v1/healthz`, `/api/v1/readyz`, `/api/v1/version` | kiko (tracking) |
| Everything else | kui (dashboard) |

**Exec / logs** (service names):

```bash
docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml logs -f traefik
docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml logs -f kiko
docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml logs -f kui
```

**kiko.js** will be served at `https://<STACK_HOSTNAME>/kiko.js`. The dashboard will be at `https://<STACK_HOSTNAME>/`.

---

**[↑ Back to run/README](../../README.md)**
