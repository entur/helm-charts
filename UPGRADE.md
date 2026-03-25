# Upgrading to common chart v2

This guide covers all breaking changes and required migration steps when upgrading from v1 to v2 of the `common` Helm chart.

## Prerequisites

- Helm 3.x or Helm 4.x
- The [kube-startup-cpu-boost](https://github.com/google/kube-startup-cpu-boost) operator installed in your cluster (enabled by default in v2). If not available, set `deployment.startupCPUBoost.enabled: false`.
- External Secrets Operator installed (required if using `postgres` or `secrets`)

## Breaking Changes

### 1. `shortname` renamed to `appId`

The `shortname` field is removed. Use `appId` instead. This aligns with the GoogleCloudApplication [`metadata.id`](https://github.com/entur/tf-gcp-apps/blob/main/docs/manifests/GoogleCloudApplication.md) field.

```yaml
# v1
common:
  shortname: myapp

# v2
common:
  appId: myapp
```

The Kubernetes label `shortname` is still emitted for backwards compatibility alongside the new `appId` label.

### 2. Scaling fields moved from `container.*` to `deployment.*`

The following fields are removed from `container` and must be set under `deployment`:

| Removed (v1) | Replacement (v2) |
|---|---|
| `container.replicas` | `deployment.replicas` |
| `container.maxReplicas` | `deployment.maxReplicas` |
| `container.forceReplicas` | `deployment.forceReplicas` |
| `container.minAvailable` | `deployment.minAvailable` |
| `container.terminationGracePeriodSeconds` | `deployment.terminationGracePeriodSeconds` |

```yaml
# v1
common:
  container:
    replicas: 2
    maxReplicas: 5

# v2
common:
  deployment:
    replicas: 2
    maxReplicas: 5
```

### 3. Cloud SQL Proxy upgraded to v2

The Cloud SQL Auth Proxy has been upgraded from v1 (1.33.16) to v2 (2.21.2). This changes how database connections are configured.

**`postgres.connectionConfig` is removed.** Use `postgres.instances` instead, which sources instance connection names from Google Secret Manager via External Secrets.

```yaml
# v1
common:
  postgres:
    enabled: true
    connectionConfig: my-app-psql-connection  # Kubernetes ConfigMap with INSTANCES env var

# v2
common:
  postgres:
    enabled: true
    instances:
      - PGINSTANCES  # Secret Manager key from entur/terraform-google-sql-db
```

**Migration steps:**

1. The `entur/terraform-google-sql-db` Terraform module already stores `PGINSTANCES` in Secret Manager. Verify it exists.
2. Replace `connectionConfig` with `instances: [PGINSTANCES]` in your values.
3. For multiple databases, list all instance keys: `instances: [PGINSTANCES, ANALYTICS_PGINSTANCES]`.
4. Remove any manual Kubernetes ConfigMaps that were providing the `INSTANCES` env var.
5. Optionally set `create_kubernetes_resources: false` in your Terraform module to stop creating the now-unused ConfigMap.

**`postgres.memoryLimit` is removed.** Memory limit is now always equal to memory request. Use `postgres.memory` to set both.

### 4. `ingress.class` annotation replaced with `spec.ingressClassName`

The deprecated `kubernetes.io/ingress.class` annotation is removed. Ingress now uses `spec.ingressClassName` (defaults to `traefik`).

If you need a different ingress class:

```yaml
common:
  ingress:
    ingressClassName: nginx
```

## New Features (no action required)

### PDB improvements
- `unhealthyPodEvictionPolicy: AlwaysAllow` prevents unhealthy pods from blocking cluster upgrades.
- PDB now correctly protects pods when `forceReplicas > 1` (was incorrectly set to 0%).

### GKE Startup CPU Boost
- Enabled by default. Temporarily increases CPU by 50% during startup, reverts when pod becomes Ready.
- HPA default `cpuUtilization` lowered from 100% to 70% since startup spikes are handled by the boost.
- Disable with `deployment.startupCPUBoost.enabled: false` if the operator is not installed.

### gRPC native probes
- Setting `grpc: true` now uses native Kubernetes gRPC probes by default, using `service.internalPort`.
- No longer requires the `/bin/grpc_health_probe` binary in your container image.
- No need to set `probes.liveness.grpc.port` etc. — ports default to `service.internalPort`.

### Startup probe path
- `container.probes.startup.path` — when set, the startup probe switches from `tcpSocket` to `httpGet`.

### Custom HPA metrics
- `hpa.metrics` — append custom metrics (Pods, External, Object) alongside default CPU scaling.
- `deployment.cpuUtilization` — set HPA CPU target (default 70%).

### Per-ingress annotations and ingressClassName
- Each entry in `ingresses` list can now have its own `annotations` and `ingressClassName`.

### Cloud SQL Proxy v2 features
- Prometheus metrics exposed on port 9801 (`/metrics`).
- Support for multiple databases via `postgres.instances` list.

## Quick Migration Checklist

- [ ] Rename `shortname` to `appId` in all values files
- [ ] Move `container.replicas` → `deployment.replicas` (and maxReplicas, forceReplicas, minAvailable, terminationGracePeriodSeconds)
- [ ] Replace `postgres.connectionConfig` with `postgres.instances: [PGINSTANCES]` (if using postgres)
- [ ] Remove `postgres.memoryLimit` (if set) — use `postgres.memory` instead
- [ ] Verify `kube-startup-cpu-boost` operator is installed, or set `deployment.startupCPUBoost.enabled: false`
- [ ] If using gRPC: remove explicit `probes.*.grpc.port` settings (now defaults to `service.internalPort`)
- [ ] Update `Chart.yaml` dependency version to v2
- [ ] Run `helm dependency update` and `helm template` to verify
