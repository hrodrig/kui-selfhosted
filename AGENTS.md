# Agent Guidelines (kui-selfhosted)

- Use **English** for all project artifacts (code, comments, commit messages, docs, README).
- **Scope:** **kui-selfhosted** owns deployment (Helm, Compose, **`run/`**, chart CI). **[kui](https://github.com/hrodrig/kui)** owns the dashboard app and image; **[kiko](https://github.com/hrodrig/kiko)** owns the collector — chart work stays in **`run/kubernetes/helm/kui/`** here.
- Follow **git flow**: work on `develop`; **`main`** for production snapshots; **annotated tags** `v<semver>` on `main` for infra releases (see root **`VERSION`**).
- **`VERSION`** (repository root): canonical **kui-selfhosted** semver (`0.1.0` style, no `v`). When it changes, align the README **Version** badge, CHANGELOG, and Git tag **`v…`** on **`main`**. **`Chart.yaml` `version:`** tracks the **Helm chart package** only.
- **`KIKO_VERSION`** / **`KUI_VERSION`** in **`${STACK_HOST_DATA}/.env`**: pin **application** OCI images — align with upstream releases; not the same as this repo’s **`VERSION`**.
- **This repo** has no Go tests; **`make release-check`** means **`helm lint`**, **`helm template`** + **kubeconform**, and **`docker compose … config`** for **minimal** (set **`STACK_HOST_DATA`**, **`KIKO_API_KEY`**, **`KUI_ADMIN_PASSWORD`**). Requires **helm**, **kubeconform**, and **docker** on **`PATH`**.
- Keep **`run/`** paths, **`STACK_HOST_DATA`**, and **`${STACK_HOST_DATA}/.env`** documentation consistent across README files (always **`--env-file`** from the clone root).
- **kiko probes:** liveness **`GET /api/v1/healthz`**, readiness **`GET /api/v1/readyz`**.
- **Secrets:** **`KIKO_API_KEY`** shared between kiko stats API and kui client; **`KUI_ADMIN_PASSWORD`** seeds kui admin. Never expose API key to browsers.
- **kiko-only** stacks live in **[kiko-selfhosted](https://github.com/hrodrig/kiko-selfhosted)**; this repo always documents **kiko + kui** together.
