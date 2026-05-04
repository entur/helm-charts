# Upgrading to common chart v2

This guide covers all breaking changes and required migration steps when upgrading from v1 to v2 of the `common` Helm chart.

## Prerequisites

- Helm 3.x or Helm 4.x
- External Secrets Operator installed (required if using `postgres` or `secrets`)
- Optionally: [kube-startup-cpu-boost](https://github.com/google/kube-startup-cpu-boost) operator for CPU boost feature

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

### 2. Scaling fields replaced

Scaling fields have been removed from `container.*` and consolidated under `deployment.*`. Additionally, `deployment.replicas` is replaced by `deployment.minReplicas`.

**HPA is now always enabled** (unless `forceReplicas` is set). The Deployment spec never emits `replicas` — HPA controls the pod count in all environments. This prevents the v1 bug where `helm upgrade` would reset HPA-managed replica counts.

| Removed (v1) | Replacement (v2) |
|---|---|
| `container.replicas` | `deployment.minReplicas` |
| `deployment.replicas` | `deployment.minReplicas` |
| `container.maxReplicas` | `deployment.maxReplicas` |
| `container.forceReplicas` | `deployment.forceReplicas` |
| `container.minAvailable` | `deployment.minAvailable` |
| `container.terminationGracePeriodSeconds` | `deployment.terminationGracePeriodSeconds` |

Default `minReplicas` by environment:
- `sbx`/`dev`/`tst`: **1** (scales down to single pod in low traffic)
- `prd`: **2** (HA by default)

```yaml
# v1
common:
  container:
    replicas: 2
    maxReplicas: 5

# v2
common:
  deployment:
    minReplicas: 2   # HPA minimum
    maxReplicas: 5   # HPA maximum
```

To disable HPA and fix a specific replica count, use `forceReplicas`:

```yaml
common:
  deployment:
    forceReplicas: 3  # disables HPA, fixed at 3 pods
```

### 3. `container.memoryLimit` removed

Memory limit is now always equal to memory request. The 1.2x multiplier and `memoryLimit` override are removed. Set `container.memory` to the value you need for both request and limit.

```yaml
# v1
common:
  container:
    memory: 512
    memoryLimit: 1024

# v2
common:
  container:
    memory: 1024  # sets both request and limit
```

### 4. Cloud SQL Proxy — `secretKeyPrefix` integration

The postgres integration now uses `secretKeyPrefix` as the single contract with the `entur/terraform-google-sql-db` Terraform module. Given a prefix, the chart derives all Secret Manager key names and fetches everything via External Secrets. Terraform-created Kubernetes secrets are no longer needed.

**`postgres.instances` format changed.** Items are now objects with `secretKeyPrefix` instead of raw Secret Manager key names. When `enabled: true` with no `instances`, the chart defaults to `[{secretKeyPrefix: PG}]`.

**`postgres.connectionConfig`, `postgres.memoryLimit`, and `postgres.termTimeout` are removed.** The `termTimeout` field is replaced by `postgres.maxSigtermDelay` to match the Cloud SQL Proxy v2 flag name.

```yaml
# v1
common:
  postgres:
    enabled: true
    connectionConfig: my-app-psql-connection

# v2 (simplest — uses default PG prefix)
common:
  postgres:
    enabled: true

# v2 (explicit prefix)
common:
  postgres:
    enabled: true
    instances:
      - secretKeyPrefix: PG

# v2 (multiple instances)
common:
  postgres:
    enabled: true
    instances:
      - secretKeyPrefix: PG
      - secretKeyPrefix: ANALYTICS_PG
```

**What changed:**

- Credentials (`{prefix}USER`, `{prefix}PASSWORD`) are now fetched from Secret Manager via External Secrets, not from a Terraform-created Kubernetes secret.
- The chart generates `{prefix}HOST=localhost` and `{prefix}PORT=5432+index` as environment variables.
- A new `sql-credentials` ExternalSecret is created alongside the existing `sql-proxy` ExternalSecret.
- `credentialsSecret` still works as an escape hatch for custom credential sources.
- `postgres.maxSigtermDelay` replaces `postgres.termTimeout` — controls the delay before the proxy begins shutdown after SIGTERM (default `30s`).

**Migration steps:**

1. Replace `instances: [PGINSTANCES]` with `instances: [{secretKeyPrefix: PG}]`, or simply use `enabled: true` for the default `PG` prefix.
2. Ensure `{prefix}USER`, `{prefix}PASSWORD`, and `{prefix}INSTANCES` exist in Secret Manager (the `entur/terraform-google-sql-db` module creates these).
3. Optionally set `create_kubernetes_resources: false` in your Terraform module — the chart no longer uses Terraform-created Kubernetes secrets.
4. For multiple databases, list each Terraform module's `secret_key_prefix` as a separate entry in `instances`.

### 5. `ingress.class` annotation replaced with `spec.ingressClassName`

The deprecated `kubernetes.io/ingress.class` annotation is removed. Ingress now uses `spec.ingressClassName` (defaults to `traefik`).

### 6. `configmap.toEnv` is removed

If you get a schema error like `configmap.toEnv is no longer valid in v2`, switch to `container.envFrom` to mount the configmap as environment variables:

```yaml
# v1
common:
  configmap:
    enabled: true
    toEnv: true
    data:
      MY_CONFIG: "value"

# v2
common:
  configmap:
    enabled: true
    data:
      MY_CONFIG: "value"
  container:
    envFrom:
      - configMapRef:
          name: my-app  # matches your release name
```

Note: The configmap is automatically mounted via `envFrom` when `configmap.enabled: true`. You only need explicit `envFrom` if you renamed the configmap or need additional control.

## New Features (no action required)

### HPA always enabled
- HPA is now enabled in all environments, not just `prd`. Default `minReplicas` is 1 for sbx/dev/tst and 2 for prd.
- When `startupCPUBoost` is disabled, a 120s scaleUp stabilization window prevents startup CPU spikes from triggering unnecessary scale-ups. Tune via `hpa.stabilizationWindowSeconds` to match your app's startup time.

### PDB improvements
- `unhealthyPodEvictionPolicy: AlwaysAllow` prevents unhealthy pods from blocking cluster upgrades.
- PDB now correctly protects pods when `forceReplicas > 1` (was incorrectly set to 0%).

### GKE Startup CPU Boost
- Disabled by default. Enable with `deployment.startupCPUBoost.enabled: true` (requires the operator installed in the cluster).
- Temporarily increases CPU by 50% during startup, reverts when pod becomes Ready.
- When enabled, a CPU limit of 1.3x the CPU request is automatically set.
- HPA default `cpuUtilization` lowered from 100% to 70%.

### gRPC native probes
- Setting `grpc: true` now uses native Kubernetes gRPC probes by default, using `service.internalPort`.
- No longer requires the `/bin/grpc_health_probe` binary in your container image.
- No need to set `probes.liveness.grpc.port` etc. — ports default to `service.internalPort`.

### Startup probe path
- `container.probes.startup.path` — when set, the startup probe switches from `tcpSocket` to `httpGet`.

### Custom HPA metrics
- `hpa.metrics` — append custom metrics (Pods, External, Object) alongside default CPU scaling.
- `deployment.cpuUtilization` — set HPA CPU target (default 70%).
- `hpa.stabilizationWindowSeconds` — tune scaleUp delay (default 120s when CPU boost is disabled).

### Per-ingress annotations and ingressClassName
- Each entry in `ingresses` list can now have its own `annotations` and `ingressClassName`.

### Cloud SQL Proxy v2 features
- Prometheus metrics exposed on port 9801 (`/metrics`).
- Support for multiple databases via `postgres.instances` list.
- `postgres.maxSigtermDelay` — configurable shutdown delay (default `30s`).

## Quick Migration Checklist

- [ ] Rename `shortname` to `appId` in all values files
- [ ] Replace `container.replicas` / `deployment.replicas` → `deployment.minReplicas`
- [ ] Replace `container.maxReplicas` → `deployment.maxReplicas`
- [ ] Replace `container.forceReplicas` → `deployment.forceReplicas`
- [ ] Replace `container.minAvailable` → `deployment.minAvailable`
- [ ] Replace `container.terminationGracePeriodSeconds` → `deployment.terminationGracePeriodSeconds`
- [ ] Remove `container.memoryLimit` / `postgres.memoryLimit` — set `memory` to the value you need
- [ ] Replace `postgres.connectionConfig` with `postgres.enabled: true` or `postgres.instances: [{secretKeyPrefix: PG}]`
- [ ] Replace `postgres.termTimeout` with `postgres.maxSigtermDelay` (if set)
- [ ] If using gRPC: remove explicit `probes.*.grpc.port` settings (now defaults to `service.internalPort`)
- [ ] Update `Chart.yaml` dependency version to v2
- [ ] Run `helm dependency update`
- [ ] Run `helm lint . -f env/values-kub-ent-dev.yaml` to catch unknown properties and schema errors
- [ ] Run `helm template . -f env/values-kub-ent-dev.yaml` to verify rendered output

## Automated upgrade with Claude Code

We provide a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills) that automates the migration. Run this in **your application's repo** (not in `helm-charts`):

### Option 1: Copy the skill into your repo

```bash
# From your application repo
mkdir -p .claude/skills
curl -sL https://raw.githubusercontent.com/entur/helm-charts/main/.claude/skills/upgrade-common-chart/SKILL.md \
  -o .claude/skills/upgrade-common-chart.md
```

Then ask Claude Code to upgrade:

```
Upgrade my common chart dependency to v2
```

The skill triggers automatically and walks through all migration steps. You can delete the skill file after the upgrade is complete.

### Option 2: Paste the migration prompt

If you prefer not to install the skill, paste this into Claude Code (or any AI coding agent):

```
Upgrade the Entur common Helm chart dependency from v1 to v2.

First, read the migration guide:
  https://raw.githubusercontent.com/entur/helm-charts/main/UPGRADE.md

Then apply the "Quick Migration Checklist" to all values files in this repository.
Run `helm dependency update` and `helm lint` to verify.
```
