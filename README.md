# kui-selfhosted

[Version](https://github.com/hrodrig/kui-selfhosted/releases)
[License: MIT](https://opensource.org/licenses/MIT)
[kui app](https://github.com/hrodrig/kui)
[kiko app](https://github.com/hrodrig/kiko)
[gghstats clones](https://gghstats.hermesrodriguez.com/hrodrig/kui-selfhosted)

Deployment manifests for **[kui](https://github.com/hrodrig/kui)** + **[kiko](https://github.com/hrodrig/kiko)** — privacy-first web analytics with a self-hosted dashboard. Compose, Helm, and **MicroK8s** raw YAML.

![kui-selfhosted hero](/assets/kui-selfhosted-hero.svg)

**Application sources:** [kui](https://github.com/hrodrig/kui) (UI + auth) · [kiko](https://github.com/hrodrig/kiko) (collector + stats API).

> For **VPS best practices** (security hardening, firewall, Docker Compose setup), see **[gghstats-selfhosted VPS recommendations](https://github.com/hrodrig/gghstats-selfhosted/tree/main/run/vps-recommended)**.

**Releases:** Root `**VERSION`** and Git tags `**v<semver>**` on `**main**` name repository snapshots. Work in progress lands on `**develop**` first.

---

## Table of contents

- [Pick a path](#pick-a-path)
- [Docker Compose minimal](#docker-compose-minimal)
- [Kubernetes Helm](#kubernetes-helm)
- [MicroK8s raw manifests](#microk8s-raw-manifests)
- [Secrets and networking](#secrets-and-networking)
- [Repository layout](#repository-layout)
- [License](#license)

---

## Pick a path


| You want…                                           | Section                                           |
| --------------------------------------------------- | ------------------------------------------------- |
| **Compose, kiko + kui** (quick VPS / lab)           | [Docker Compose minimal](#docker-compose-minimal) |
| **Kubernetes / Helm** (MicroK8s, kind, any cluster) | [Kubernetes Helm](#kubernetes-helm)               |
| **Plain YAML on MicroK8s** (no Helm)                | [MicroK8s raw manifests](#microk8s-raw-manifests) |


Shared env template: `**[run/common/.env.example](run/common/.env.example)`**. Walkthroughs: `**[run/README.md](run/README.md)**`.

Default image tags: `**KIKO_VERSION**` / `**KUI_VERSION**` (see [kiko](https://github.com/hrodrig/kiko/releases) and [kui](https://github.com/hrodrig/kui/releases) releases).

---

## Docker Compose minimal

```bash
export STACK_HOST_DATA=/home/kui/stack-data
mkdir -p "$STACK_HOST_DATA/kiko-data" "$STACK_HOST_DATA/kui-data"
cp run/common/.env.example "$STACK_HOST_DATA/.env"
# edit STACK_HOST_DATA, KIKO_API_KEY, KUI_ADMIN_PASSWORD, KIKO_PUBLIC_URL

docker compose --env-file "$STACK_HOST_DATA/.env" \
  -f run/docker-compose/minimal/docker-compose.yml up -d

curl -sS http://127.0.0.1:8080/api/v1/healthz
open http://127.0.0.1:3000
```

Details: `**[run/docker-compose/minimal/README.md](run/docker-compose/minimal/README.md)**`.

---

## Kubernetes Helm

```bash
helm upgrade --install kui run/kubernetes/helm/kui \
  --namespace kui --create-namespace \
  --set secrets.kikoApiKey='your-api-key' \
  --set secrets.kuiAdminPassword='your-admin-password' \
  --set kiko.image.tag=v0.5.0 \
  --set kui.image.tag=v0.3.2 \
  --set kiko.env.publicUrl=https://analytics.example.com
```

Chart README: `**[run/kubernetes/helm/kui/README.md](run/kubernetes/helm/kui/README.md)**`.

---

## MicroK8s raw manifests

```bash
# Edit run/kubernetes/manifests/microk8s/03-secret.yaml first
microk8s enable dns storage
kubectl apply -f run/kubernetes/manifests/microk8s/
kubectl -n kui port-forward svc/kui 3000:3000
```

See `**[run/kubernetes/manifests/microk8s/README.md](run/kubernetes/manifests/microk8s/README.md)**`.

---

## First-party proxy example

To avoid ad blockers and comply with CSP, **never** point `kiko.js` directly at your kiko domain. Serve the script and endpoints from **your own domain** via a reverse proxy. Hits look like first-party traffic and browsers won't block them.

This example is based on a real deployment where **the same site** is served on two environments (`dev.example.com` for UAT, `example.com` for production) and the analytics tracker must point to the correct domain per environment.

### 1. Reverse proxy (nginx)

Add these `location` blocks to your site's nginx config:

```nginx
# JS script (cacheable 1h)
location /kiko/kiko.js {
    proxy_pass https://kiko-backend:8080/kiko.js;
    proxy_set_header Host kiko-backend;
    proxy_hide_header Content-Security-Policy;
    proxy_cache_valid 200 1h;
    expires 1h;
    add_header Cache-Control "public";
}

# POST /api — sendBeacon tracking
location /kiko/api {
    proxy_pass https://kiko-backend:8080/api;
    proxy_set_header Host kiko-backend;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
}

# GET /api.gif — pixel fallback
location /kiko/api.gif {
    proxy_pass https://kiko-backend:8080/api.gif;
    proxy_set_header Host kiko-backend;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

> **Traefik / Caddy / Cloudflare:** same principle — route `/kiko/`* to the kiko backend preserving the client IP. See [kiko-selfhosted → Behind a reverse proxy](https://github.com/hrodrig/kiko-selfhosted#behind-a-reverse-proxy).

### 2. Environment variable `PUBLIC_KIKO_BASE`

Each environment defines the proxy base URL. The tracker uses this variable to build the script and endpoint URLs.


| Environment       | `PUBLIC_KIKO_BASE`             |
| ----------------- | ------------------------------ |
| Development / UAT | `https://dev.example.com/kiko` |
| Production        | `https://example.com/kiko`     |


Example in HTML (or your SSG template of choice):

```html
<script defer
        src="https://example.com/kiko/kiko.js"
        data-endpoint="https://example.com/kiko"
        id="kiko-tracker">
</script>
```

#### Astro example (`BaseHead.astro`)

In Astro, the variable is read at build-time via `import.meta.env.PUBLIC_*`. Add a fallback so it works on local dev as well:

```astro
---
const kikoBase = import.meta.env.PUBLIC_KIKO_BASE || 'https://dev.example.com/kiko';
---
<script defer
        src={`${kikoBase}/kiko.js`}
        data-endpoint={kikoBase}
        id="kiko-tracker">
</script>
```

Same pattern applies to any SSG (Next.js, Hugo, Eleventy, etc.) — pass `PUBLIC_KIKO_BASE` at build time and reference it in the template.

![kiko+kui live](/assets/kiko+kui-live.png)

### 3. Build-time (CI/CD pipeline)

If you have a CI/CD pipeline that builds Docker images for your web projects, you can adjust it to inject `PUBLIC_KIKO_BASE` at build time. The important thing is that the variable ends up in the `<script defer ...>` tag included in the `<head>` of your site.

Example with GitLab CI — each branch injects its own value:

```yaml
# .gitlab-ci.yml
build-job:
  script:
    - |
      docker buildx build \
        --build-arg SITE_URL="${SITE_URL}" \
        --build-arg PUBLIC_KIKO_BASE="${PUBLIC_KIKO_BASE}" \
        -t app:latest .
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      variables:
        PUBLIC_KIKO_BASE: "https://example.com/kiko"
    - if: $CI_COMMIT_BRANCH == "uat"
      variables:
        PUBLIC_KIKO_BASE: "https://dev.example.com/kiko"
```

In the Dockerfile:

```dockerfile
ARG PUBLIC_KIKO_BASE=https://example.com/kiko
ENV PUBLIC_KIKO_BASE=${PUBLIC_KIKO_BASE}
RUN npm run build   # the SSG (Astro, Next, etc.) reads it at build-time
```

### 4. CSP (Content-Security-Policy)

Since you're now serving kiko from your own domain, no external domains need to be added to `script-src` or `connect-src`. A CSP like this is sufficient:

```nginx
add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self';
    connect-src 'self';
    img-src 'self' data: https: blob:;
" always;
```

Analytics traffic goes to your own `www.example.com/kiko/api`, so `connect-src 'self'` covers it without exceptions.

### 5. kiko.js auto-detection

The script supports three mechanisms to determine the endpoint (in priority order):

1. `**data-endpoint**` on the `<script>` tag (recommended)
2. **Extract the base from `script.src`** (useful when only setting `src`)
3. **Use `window.location.origin`** (last resort, when neither can be determined)

This lets you use the same `kiko.js` without modifications regardless of framework or environment.

Anyone can audit the full source at [github.com/hrodrig/kiko/blob/main/internal/server/kiko.js](https://github.com/hrodrig/kiko/blob/main/internal/server/kiko.js).

---

## Secrets and networking


| Secret                   | Used by    | Purpose                                               |
| ------------------------ | ---------- | ----------------------------------------------------- |
| `**KIKO_API_KEY**`       | kiko + kui | Locks kiko stats API; kui calls kiko server-side only |
| `**KUI_ADMIN_PASSWORD**` | kui        | Seeds first admin on empty `kui.db`                   |


Typical production layout:


| Host                    | Backend | Traffic                       |
| ----------------------- | ------- | ----------------------------- |
| `analytics.example.com` | kiko    | `kiko.js`, `/hit`, `/hit.gif` |
| `dashboard.example.com` | kui     | Login, charts, admin UI       |


In Compose, **kiko** publishes `${KIKO_HOST_PORT}`; **kui** publishes `${KUI_HOST_PORT}`. In Kubernetes, use Ingress (see commented examples).

**kiko probes:** liveness `GET /api/v1/healthz`, readiness `GET /api/v1/readyz`.

---

## Repository layout

```
run/
  common/                 # .env.example (stack)
  docker-compose/minimal/ # kiko + kui
  kubernetes/
    helm/kui/             # Helm chart (both services)
    manifests/microk8s/   # plain YAML
```

**kiko-only** deployments remain in **[kiko-selfhosted](https://github.com/hrodrig/kiko-selfhosted)**.

---

## License

MIT — see [LICENSE](LICENSE).