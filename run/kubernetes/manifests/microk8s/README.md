# MicroK8s — kiko + kui stack

Plain YAML for a single-node **MicroK8s** cluster (Traefik ingress add-on optional).

## Apply

```bash
# Edit 03-secret.yaml (KIKO_API_KEY, KUI_ADMIN_PASSWORD) first
microk8s enable dns storage
kubectl apply -f run/kubernetes/manifests/microk8s/

kubectl -n kui wait --for=condition=ready pod -l app.kubernetes.io/name=kiko --timeout=120s
kubectl -n kui wait --for=condition=ready pod -l app.kubernetes.io/name=kui --timeout=120s

kubectl -n kui port-forward svc/kiko 8080:8080 &
kubectl -n kui port-forward svc/kui 3000:3000 &
curl -sS http://127.0.0.1:8080/api/v1/readyz
open http://127.0.0.1:3000
```

## Ingress

Uncomment and edit [`10-ingress.yaml`](10-ingress.yaml) for two hosts:

- **analytics.example.com** → kiko (tracking script + hits)
- **dashboard.example.com** → kui (login + charts)

## Images

Default: `ghcr.io/hrodrig/kiko:v0.1.0` and `ghcr.io/hrodrig/kui:v0.1.0`. Bump tags in Deployments when new app releases ship.
