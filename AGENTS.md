# AGENTS.md — Entur Helm Charts

## Project Overview

This repository contains Entur's opinionated Helm charts for deploying applications to Kubernetes. The primary chart is `common` (in `charts/common/`), which provides a convention-over-configuration approach for Spring Boot apps and general workloads. Example charts in `examples/common/` demonstrate usage patterns.

Compatible with Helm 3 and Helm 4.

## Repository Structure

```
charts/common/           # The main Helm chart (source of truth)
  templates/             # Kubernetes resource templates
  tests/                 # helm-unittest test suites
  tests/values/          # Shared test values
  values.yaml            # Default values (heavily documented)
  values.schema.json     # JSON Schema for values validation
examples/common/         # 7 example charts showing usage patterns
fixture/helm/            # Fixture values for template rendering validation
.github/workflows/       # CI/CD (PR checks, release, docs generation)
```

## Tools

- **`helm`** — render templates, manage dependencies, package charts
- **`helm unittest`** — run YAML-based unit tests (plugin: helm-unittest)
- **`helm template`** — render and inspect template output with fixture values
- **`helm lint`** — validate chart structure and values against JSON Schema
- **`helm-docs`** — auto-generate README.md from values.yaml comments and Chart.yaml description
- **`gh`** — GitHub CLI for issues, PRs, releases, and CI status

## Development Commands

```bash
# Run unit tests (primary validation step — always run after any template/values change)
helm unittest ./charts/common

# Run a single test file
helm unittest ./charts/common -f tests/pdb_test.yaml

# Lint chart with schema validation
helm lint charts/common -f fixture/helm/values-minimal.yaml

# Render templates with fixture values to verify output
helm template charts/common -f fixture/helm/values-minimal.yaml
helm template charts/common -f fixture/helm/values-cron.yaml
helm template charts/common -f fixture/helm/values-secrets.yaml
helm template charts/common -f fixture/helm/values-postgres.yaml
helm template charts/common -f fixture/helm/values-postgres-multi.yaml

# Render a single template
helm template test charts/common -f fixture/helm/values-minimal.yaml --show-only templates/pdb.yaml

# Render with value overrides (useful for testing specific scenarios)
helm template test charts/common -f fixture/helm/values-minimal.yaml --set env=prd --set deployment.minReplicas=3

# Regenerate chart documentation (README.md files) — run after changing values.yaml or Chart.yaml
helm-docs

# Update dependencies for example charts after version bump
helm dependency update examples/common/<example-name>

# View GitHub issues
gh issue view <number> --repo entur/helm-charts
gh issue view <number> --repo entur/helm-charts --comments
```

## Testing

- **Framework**: [helm-unittest](https://github.com/helm-unittest/helm-unittest) — YAML-based declarative assertions
- **Test location**: `charts/common/tests/*_test.yaml`
- **Shared test values**: `charts/common/tests/values/common-test-values.yaml`
- **Snapshots**: `charts/common/tests/__snapshot__/`
- **Always run `helm unittest ./charts/common` after modifying any template or values**
- Tests cover: deployment, service, ingress, HPA, PDB, VPA, configmap, secrets, cron, sql-proxy, sql-credentials

## Key Conventions

### Commit Messages
Uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
- `feat!:` — breaking change (major version bump)
- `feat:` — new feature (minor version bump)
- `fix:` — bug fix (patch version bump)
- `docs:` / `ci:` / `chore:` — no version bump

### Chart Design Principles
- HPA is always enabled with `minReplicas: 2` by default (use `forceReplicas` to opt out)
- Memory limit always equals memory request
- Security: non-root, no privilege escalation, drop all capabilities, seccompProfile RuntimeDefault
- Traffic types must be explicit: `api`, `public`, or `http2`
- Template helpers are in `charts/common/templates/_helpers.tpl`
- Deprecated values use `fail` to give clear migration messages
- Scaling fields (minReplicas, maxReplicas, forceReplicas, minAvailable) belong under `deployment.*` only — not `container.*`
- Container-specific fields (cpu, memory, image, probes, env, ports, lifecycle) belong under `container.*`

### Values Patterns
- Required fields: `app`, `appId`, `team`, `env`, `container.image`
- Environment values: `sbx`, `dev`, `tst`, `prd`
- Single container: use `container:` key
- Multiple containers: use `containers:` list
- Environment-specific overrides go in `env/values-kub-ent-{dev,tst,prd}.yaml`
- Postgres/Cloud SQL: `postgres.enabled: true` defaults to `secretKeyPrefix: PG`. For multiple instances use `postgres.instances: [{secretKeyPrefix: PG}, {secretKeyPrefix: ANALYTICS_PG}]`. The `secretKeyPrefix` is the contract with the `entur/terraform-google-sql-db` Terraform module — it derives Secret Manager keys `{prefix}INSTANCES`, `{prefix}USER`, `{prefix}PASSWORD`
- gRPC: set `grpc: true` — native K8s gRPC probes are used automatically with `service.internalPort`
- Custom HPA metrics: use `hpa.metrics` list to add Pods/External/Object metrics alongside default CPU

### Documentation
- `README.md` files in `charts/` and `examples/` are **auto-generated** by `helm-docs` — never edit them manually
- To update documentation: edit `values.yaml` comments (use `# --` prefix for helm-docs) or `Chart.yaml` description, then run `helm-docs`
- After any change to `values.yaml`, `Chart.yaml`, or `values.schema.json`: run `helm-docs` to regenerate README.md files
- `values.schema.json` must be updated manually when adding/removing/renaming values fields

## CI/CD

- **PR checks**: lint, unit tests (Helm 3 + 4), kind cluster install tests (Helm 3 + 4), example validation (Helm 3 + 4)
- **Release**: automated via release-please with semantic versioning; tags like `common-v2.0.0`
- **Docs**: auto-generated on release branches via helm-docs workflow
- **Ownership**: `@entur/team-plattform` (see CODEOWNERS)

## Important Notes

- `README.md` files in charts are **auto-generated** by helm-docs — do not edit them manually; edit `values.yaml` comments or `Chart.yaml` description instead
- Example charts pin their dependency on `common` — update both `Chart.yaml` version and run `helm dependency update` when changing
- The chart supports both Deployment and CronJob workloads (mutually exclusive via `deployment.enabled` / `cron.enabled`)
- Fixture values in `fixture/helm/` are used for CI template rendering validation
- `shortname` is removed — use `appId` (matches GoogleCloudApplication `metadata.id`)
- `postgres.connectionConfig` is removed — use `postgres.enabled: true` (defaults to `secretKeyPrefix: PG`)
- `postgres.termTimeout` is removed — use `postgres.maxSigtermDelay`
- `deployment.replicas` is removed — use `deployment.minReplicas` (HPA controls pod count)
- `container.memoryLimit` is removed — memory limit always equals memory request
- `pdb.minAvailable` is removed — use `deployment.minAvailable`
