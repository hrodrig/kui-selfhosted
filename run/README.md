# How to run kui + kiko (self-hosted)

← [Back to the repository README](../README.md).

| Directory | When to use |
|-----------|-------------|
| [`run/common/`](common/) | Shared **environment template** for Compose. Copy to **`${STACK_HOST_DATA}/.env`**. |
| [`docker-compose/minimal/`](docker-compose/minimal/) | **kiko + kui** — SQLite on bind mounts, quick VPS or lab. |
| [`kubernetes/helm/kui/`](kubernetes/helm/kui/) | **Helm chart** — MicroK8s, kind, production clusters. |
| [`kubernetes/manifests/microk8s/`](kubernetes/manifests/microk8s/) | **Plain YAML** — apply with `kubectl` on MicroK8s without Helm. |

Pin image tags to your desired releases: **`KIKO_VERSION`** / **`KUI_VERSION`** in [`.env.example`](common/.env.example).

**kiko probes:** liveness **`/api/v1/healthz`**, readiness **`/api/v1/readyz`**.

**kui:** HTTP UI on port **3000** (no separate health endpoint yet — use TCP or HTTP `GET /login`).

---

**[↑ Back to the repository README](../README.md)**
