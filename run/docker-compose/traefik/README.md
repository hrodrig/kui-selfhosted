# Traefik + TLS (production-style)

← [Back to run/README](../../README.md).

**Traefik** terminates HTTPS (Let's Encrypt) and routes to **kiko** and **kui** on separate subdomains. Each service gets its own TLS certificate. No host ports are published for kiko or kui; only **80** and **443** for Traefik.

| Service | Hostname |
|---------|----------|
| kiko (tracking) | `https://<KIKO_HOSTNAME>` — `/hit`, `/kiko.js`, `/api/v1/stats/*` |
| kui (dashboard) | `https://<KUI_HOSTNAME>` — login, charts, admin |

Compose **project** `kui-edge` (containers `kui-edge-traefik-1`, `kui-edge-kiko-1`, `kui-edge-kui-1`).

**Traefik image:** pinned in [`docker-compose.yml`](docker-compose.yml) (currently **`traefik:v3.7.5`**, 3.7.x line). Stay on **≥ v3.6.14** for published security fixes.

From the **repository root**:

```bash
export STACK_HOST_DATA=/home/kui/stack-data
mkdir -p "$STACK_HOST_DATA/kiko-data" "$STACK_HOST_DATA/kui-data"
cp run/common/.env.example "${STACK_HOST_DATA}/.env"
# Set KIKO_HOSTNAME, KUI_HOSTNAME, ACME_EMAIL, KIKO_VISITOR_SALT,
# KIKO_API_KEY, KUI_ADMIN_PASSWORD, and STACK_HOST_DATA

docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml up -d
```

Or use the helper script (recommended):

```bash
./run/scripts/compose-stack.sh up          # full stack
./run/scripts/compose-stack.sh up kiko     # collector only
./run/scripts/compose-stack.sh up kiko kui # apps only, keep Traefik running
./run/scripts/compose-stack.sh down        # stop everything
./run/scripts/compose-stack.sh logs kiko   # follow kiko logs
```

Ensure DNS for both `KIKO_HOSTNAME` and `KUI_HOSTNAME` points to this host and **80/443** are reachable for ACME.

**Exec / logs** (service names):

```bash
docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml logs -f traefik
docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml logs -f kiko
docker compose --env-file "${STACK_HOST_DATA}/.env" \
  -f run/docker-compose/traefik/docker-compose.yml logs -f kui
```

**kiko.js** will be served at `https://<KIKO_HOSTNAME>/kiko.js`. The dashboard will be at `https://<KUI_HOSTNAME>/`.

---

**[↑ Back to run/README](../../README.md)**
