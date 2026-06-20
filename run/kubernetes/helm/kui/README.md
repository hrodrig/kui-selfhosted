# Helm chart — kiko + kui stack

Deploys **kiko** (collector + stats API) and **kui** (dashboard) in one release.

## Install

```bash
helm upgrade --install kui run/kubernetes/helm/kui \
  --namespace kui --create-namespace \
  --set secrets.kikoApiKey='your-api-key' \
  --set secrets.kuiAdminPassword='your-admin-password' \
  --set kiko.env.publicUrl=https://analytics.example.com
```

## Values

| Key | Description |
|-----|-------------|
| `secrets.kikoApiKey` | Shared secret — kiko stats API + kui client |
| `secrets.kuiAdminPassword` | First admin password (kui SQLite) |
| `kiko.image.tag` | kiko OCI tag |
| `kui.image.tag` | kui OCI tag |
| `kiko.env.publicUrl` | Public URL for `kiko.js` |
| `kiko.env.allowedHosts` | Comma-separated hit allowlist |

## Ingress

This chart does not ship Ingress by default. Point two hosts at the Services:

- **analytics.example.com** → kiko Service (tracking)
- **dashboard.example.com** → kui Service (UI)

See MicroK8s example: [`../manifests/microk8s/10-ingress.yaml`](../manifests/microk8s/10-ingress.yaml).
