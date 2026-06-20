# Compose minimal — kiko + kui

← [Back to docker-compose](../README.md).

Two containers on one Compose network:

| Service | Role | Published port |
|---------|------|----------------|
| **kiko** | Collector + stats API | `${KIKO_HOST_PORT}` (default `8080`) — tracking + internal API |
| **kui** | Dashboard UI | `${KUI_HOST_PORT}` (default `3000`) |

**kui** reaches **kiko** at `http://kiko:8080` with `KIKO_API_KEY` (never exposed to browsers).

## Quick start

```bash
export STACK_HOST_DATA=/home/kui/stack-data
mkdir -p "$STACK_HOST_DATA/kiko-data" "$STACK_HOST_DATA/kui-data"
cp run/common/.env.example "$STACK_HOST_DATA/.env"
# edit STACK_HOST_DATA, KIKO_API_KEY, KUI_ADMIN_PASSWORD, KIKO_PUBLIC_URL, KIKO_ALLOWED_HOSTS

docker compose --env-file "$STACK_HOST_DATA/.env" \
  -f run/docker-compose/minimal/docker-compose.yml up -d

curl -sS http://127.0.0.1:8080/api/v1/healthz
open http://127.0.0.1:3000
```

Sign in with `KUI_ADMIN_EMAIL` / `KUI_ADMIN_PASSWORD`.

## Tracking script

Add to your site (replace with your public kiko URL):

```html
<script defer src="https://analytics.example.com/kiko.js"></script>
```

Set **`KIKO_PUBLIC_URL`** to that origin. The dashboard stays on **`KUI_HOST_PORT`** (or a reverse proxy in front of kui).

## Images

Default tags: **`ghcr.io/hrodrig/kiko:${KIKO_VERSION}`** and **`ghcr.io/hrodrig/kui:${KUI_VERSION}`**. Build locally from app repos if GHCR tags are not published yet.

---

**[↑ Back to docker-compose](../README.md)**
