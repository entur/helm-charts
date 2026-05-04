---
name: upgrade-common-chart
description: >
  Upgrade Entur common Helm chart dependency from v1 to v2. Use this skill when
  the user wants to migrate their Helm values files to the v2 common chart, asks
  about upgrading to common chart v2, mentions "common chart upgrade", or has
  schema validation errors after bumping the common chart version. Also trigger
  when the user mentions deprecated fields like shortname, container.replicas,
  connectionConfig, memoryLimit, or postgres.instances with raw string values.
---

# Upgrade Entur Common Helm Chart (v1 to v2)

You are upgrading a Helm chart that depends on `entur/common` from v1 to v2. This is a breaking change that requires migrating values files and updating the chart dependency.

## Step 1: Understand the project

Find all relevant files:
1. `Chart.yaml` — contains the `common` dependency version to update
2. All `values*.yaml` files — contain the values to migrate (check `env/` subdirectories too)
3. Any `values-kub-ent-*.yaml` files — environment-specific overrides

Read each file before making changes. The common chart is typically referenced as a dependency under the `common:` key in values files.

## Step 2: Update Chart.yaml

Bump the common chart dependency version to `2.0.0`:

```yaml
dependencies:
  - name: common
    version: 2.0.0
    repository: "https://entur.github.io/helm-charts"
```

## Step 3: Apply migrations to every values file

Work through each migration in order. Skip any that don't apply to the file.

### 3.1 Rename `shortname` to `appId`

```yaml
# Before
common:
  shortname: myapp

# After
common:
  appId: myapp
```

### 3.2 Move scaling fields from `container.*` to `deployment.*`

| Removed (v1) | Replacement (v2) |
|---|---|
| `container.replicas` | `deployment.minReplicas` |
| `deployment.replicas` | `deployment.minReplicas` |
| `container.maxReplicas` | `deployment.maxReplicas` |
| `container.forceReplicas` | `deployment.forceReplicas` |
| `container.minAvailable` | `deployment.minAvailable` |
| `container.terminationGracePeriodSeconds` | `deployment.terminationGracePeriodSeconds` |

HPA is now always enabled (unless `forceReplicas` is set). The Deployment never emits a `replicas` field — HPA controls pod count. To pin replicas, use `deployment.forceReplicas`.

### 3.3 Remove `container.memoryLimit` and `postgres.memoryLimit`

Memory limit now always equals memory request. Remove `memoryLimit` and set `memory` to the value you need for both.

### 3.4 Migrate postgres configuration

This is the most significant change. The postgres integration now uses `secretKeyPrefix` as the contract with the `entur/terraform-google-sql-db` Terraform module.

**Remove deprecated fields:** `postgres.connectionConfig`, `postgres.memoryLimit`, `postgres.termTimeout`

**Migrate `postgres.instances`:** Items changed from raw Secret Manager key names (strings) to objects with `secretKeyPrefix`. When `enabled: true` with no `instances`, the chart defaults to `[{secretKeyPrefix: PG}]`.

```yaml
# v1
common:
  postgres:
    enabled: true
    connectionConfig: my-app-psql-connection

# v2 (simplest — default PG prefix)
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

If `postgres.termTimeout` was set, rename it to `postgres.maxSigtermDelay` (maps to the Cloud SQL Proxy v2 `--max-sigterm-delay` flag).

### 3.5 Remove `configmap.toEnv`

The configmap is automatically mounted via `envFrom` when `configmap.enabled: true`.

```yaml
# v1
common:
  configmap:
    enabled: true
    toEnv: true

# v2
common:
  configmap:
    enabled: true
```

### 3.6 Update ingress if using `ingress.class`

The `kubernetes.io/ingress.class` annotation is removed. Ingress now uses `spec.ingressClassName` (defaults to `traefik`). If you had a custom `ingress.class` annotation, use `ingress.ingressClassName` instead.

### 3.7 Update gRPC probe configuration

If using gRPC, explicit `probes.*.grpc.port` settings are no longer needed — they default to `service.internalPort`. Remove them unless you need a non-default port.

## Step 4: Verify

Run these commands and fix any issues:

```bash
helm dependency update
helm lint . -f env/values-kub-ent-dev.yaml
helm template . -f env/values-kub-ent-dev.yaml
```

If lint reports unknown properties, you likely missed a renamed or removed field. Check the migration steps above.

## Step 5: Summary

After completing all changes, provide the user with a summary of what was changed, organized by file. Mention any fields that were removed or renamed.
