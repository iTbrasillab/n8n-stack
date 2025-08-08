# n8n-stack Helm Chart

This repository contains a **self-contained Helm stack** for deploying:

- **n8n** (API + Worker)
- **PostgreSQL** (internal StatefulSet)
- **Redis** (internal StatefulSet)
- **Evolution API**

No external chart dependencies — everything is defined here for easy, repeatable installs.

---

## 1. Prerequisites

- Kubernetes cluster (tested with kubeadm on Oracle Linux 8)
- `kubectl` and `helm` installed
- Node(s) with enough storage for local PVs
- Optional: Ingress controller (NGINX or Traefik) if you want external access

---

## 2. Clone the repository

```bash
git clone https://github.com/iTbrasillab/n8n-stack.git
cd n8n-stack
```

## 3 .Config Values 

Default configuration is in values.yaml.
For local deployments, create a values.local.yaml to override only what you need:

Example values.local.yaml:

```yaml
Copiar
Editar
global:
  db:
    user: n8n
    password: itn8nlocal
    name: n8n
  redis:
    uri: "redis://:redispass@n8n-stack-redis.n8n-stack.svc.cluster.local:6379/6"

n8n:
  image:
    repository: n8nio/n8n
    tag: 1.55.1
    pullPolicy: IfNotPresent

evolutionApi:
  secretEnv:
    DATABASE_PROVIDER: "postgresql"
    DATABASE_CONNECTION_URI: "postgresql://n8n:changeme@n8n-stack-postgresql.n8n-stack.svc.cluster.local:5432/evoapi?schema=evolution_api"
    DATABASE_CONNECTION_CLIENT_NAME: "evolution_exchange"
    CACHE_REDIS_URI: "redis://:redispass@n8n-stack-redis.n8n-stack.svc.cluster.local:6379/6"
```
## 4. Install the stack
Create a namespace (optional but recommended):

```bash
kubectl create ns n8n-stack
```
Install with local overrides:

```bash
helm install n8n-stack . -n n8n-stack -f values.local.yaml
```

## 5. Verify deployment
Check pods:

```bash
kubectl get pods -n n8n
```
You should see Running for:

n8n-stack-api

n8n-stack-worker

n8n-stack-postgresql

n8n-stack-redis

n8n-stack-evo

## 6. Accessing the services
Without Ingress
Port-forward:

```bash
kubectl port-forward svc/n8n-api 5678:5678 -n n8n
kubectl port-forward svc/evolution-api 8080:8080 -n n8n
```
Then visit:

n8n: http://localhost:5678

Evolution API: http://localhost:8080

With Ingress
Edit values.local.yaml to configure:

```yaml
n8n:
  ingress:
    enabled: true
    hosts:
      - host: n8n.local
        paths: ["/"]

evolutionApi:
  ingress:
    enabled: true
    hosts:
      - host: evo.local
        paths: ["/"]
```
Make sure DNS or /etc/hosts points to your ingress controller.

## 7. Uninstall
```bash
helm uninstall n8n-stack -n n8n-stack
kubectl delete ns n8n-stack
```
Notes
This stack does not use cert-manager by default.

For production, review values.yaml for resource requests/limits, persistence settings, and authentication secrets.

You can override any setting from values.yaml in your own values.local.yaml.

