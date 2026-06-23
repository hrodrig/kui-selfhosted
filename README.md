# kui-selfhosted

[![Version](https://img.shields.io/badge/version-0.1.9-blue)](https://github.com/hrodrig/kui-selfhosted/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![kui app](https://img.shields.io/badge/app-hrodrig%2Fkui-181717?logo=github)](https://github.com/hrodrig/kui)
[![kiko app](https://img.shields.io/badge/collector-hrodrig%2Fkiko-181717?logo=github)](https://github.com/hrodrig/kiko)
[![gghstats clones](https://gghstats.hermesrodriguez.com/api/v1/badge/hrodrig/kui-selfhosted?metric=clones)](https://gghstats.hermesrodriguez.com/hrodrig/kui-selfhosted)

Deployment manifests for **[kui](https://github.com/hrodrig/kui)** + **[kiko](https://github.com/hrodrig/kiko)** — privacy-first web analytics with a self-hosted dashboard. Compose, Helm, and **MicroK8s** raw YAML.

[![kui-selfhosted hero](/assets/kui-selfhosted-hero.svg)](/assets/kui-selfhosted-hero.svg)

**Application sources:** [kui](https://github.com/hrodrig/kui) (UI + auth) · [kiko](https://github.com/hrodrig/kiko) (collector + stats API).

> For **VPS best practices** (security hardening, firewall, Docker Compose setup), see **[gghstats-selfhosted VPS recommendations](https://github.com/hrodrig/gghstats-selfhosted/tree/main/run/vps-recommended)**.

**Releases:** Root **`VERSION`** and Git tags **`v<semver>`** on **`main`** name repository snapshots. Work in progress lands on **`develop`** first.

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

| You want… | Section |
|-----------|---------|
| **Compose, kiko + kui** (quick VPS / lab) | [Docker Compose minimal](#docker-compose-minimal) |
| **Kubernetes / Helm** (MicroK8s, kind, any cluster) | [Kubernetes Helm](#kubernetes-helm) |
| **Plain YAML on MicroK8s** (no Helm) | [MicroK8s raw manifests](#microk8s-raw-manifests) |

Shared env template: **[`run/common/.env.example`](run/common/.env.example)**. Walkthroughs: **[`run/README.md`](run/README.md)**.

Default image tags: **`KIKO_VERSION`** / **`KUI_VERSION`** (see [kiko](https://github.com/hrodrig/kiko/releases) and [kui](https://github.com/hrodrig/kui/releases) releases).

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

Details: **[`run/docker-compose/minimal/README.md`](run/docker-compose/minimal/README.md)**.

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

Chart README: **[`run/kubernetes/helm/kui/README.md`](run/kubernetes/helm/kui/README.md)**.

---

## MicroK8s raw manifests

```bash
# Edit run/kubernetes/manifests/microk8s/03-secret.yaml first
microk8s enable dns storage
kubectl apply -f run/kubernetes/manifests/microk8s/
kubectl -n kui port-forward svc/kui 3000:3000
```

See **[`run/kubernetes/manifests/microk8s/README.md`](run/kubernetes/manifests/microk8s/README.md)**.

---

## Secrets and networking

| Secret | Used by | Purpose |
|--------|---------|---------|
| **`KIKO_API_KEY`** | kiko + kui | Locks kiko stats API; kui calls kiko server-side only |
| **`KUI_ADMIN_PASSWORD`** | kui | Seeds first admin on empty `kui.db` |

Typical production layout:

| Host | Backend | Traffic |
|------|---------|---------|
| `analytics.example.com` | kiko | `kiko.js`, `/hit`, `/hit.gif` |
| `dashboard.example.com` | kui | Login, charts, admin UI |

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
