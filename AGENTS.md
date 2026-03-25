# AGENTS.md — Entur Helm Charts

## Project Overview

This repository contains Entur's opinionated Helm charts for deploying applications to Kubernetes. The primary chart is `common` (in `charts/common/`), which provides a convention-over-configuration approach for Spring Boot apps and general workloads. Example charts in `examples/common/` demonstrate usage patterns.

## Repository Structure

```
charts/common/           # The main Helm chart (source of truth)
  templates/             # Kubernetes resource templates
  tests/                 # helm-unittest test suites
  tests/values/          # Shared test values
  values.yaml            # Default values (heavily documented)
examples/common/         # 7 example charts showing usage patterns
fixture/helm/            # Fixture values for template rendering validation
.github/workflows/       # CI/CD (PR checks, release, docs generation)
```

## Development Commands

```bash
# Run unit tests (primary validation step)
helm unittest ./charts/common

# Render templates with fixture values to verify output
helm template charts/common -f fixture/helm/values-minimal.yaml
helm template charts/common -f fixture/helm/values-cron.yaml
helm template charts/common -f fixture/helm/values-secrets.yaml
helm template charts/common -f fixture/helm/values-postgres.yaml

# Regenerate chart documentation (README.md files)
helm-docs

# Update dependencies for example charts after version bump
helm dependency update examples/common/<example-name>
```

## Testing

- **Framework**: [helm-unittest](https://github.com/helm-unittest/helm-unittest) — YAML-based declarative assertions
- **Test location**: `charts/common/tests/*_test.yaml`
- **Shared test values**: `charts/common/tests/values/common-test-values.yaml`
- **Snapshots**: `charts/common/tests/__snapshot__/`
- **Always run `helm unittest ./charts/common` after modifying any template or values**
- Tests cover: deployment, service, ingress, HPA, PDB, VPA, configmap, secrets, cron, and v1 backward compatibility

## Key Conventions

### Commit Messages
Uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
- `feat!:` — breaking change (major version bump)
- `feat:` — new feature (minor version bump)
- `fix:` — bug fix (patch version bump)
- `docs:` / `ci:` / `chore:` — no version bump

### Chart Design Principles
- Environment-aware defaults: `prd` automatically enables HA (HPA, PDB)
- Resource convention: CPU limit = 5x request, memory limit = 1.2x request
- Security: non-root, no privilege escalation, drop all capabilities
- Traffic types must be explicit: `api`, `public`, or `http2`
- Template helpers are in `charts/common/templates/_helpers.tpl`

### Values Patterns
- Required fields: `app`, `team`, `env`, `container.image`
- Environment values: `dev`, `tst`, `prd`
- Single container: use `container:` key
- Multiple containers: use `containers:` list
- Environment-specific overrides go in `env/values-kub-ent-{dev,tst,prd}.yaml`

## CI/CD

- **PR checks**: lint, unit tests, kind cluster install tests across all examples and environments
- **Release**: automated via release-please with semantic versioning; tags like `common-v1.21.1`
- **Docs**: auto-generated on release branches via helm-docs workflow
- **Ownership**: `@entur/team-plattform` (see CODEOWNERS)

## Important Notes

- `README.md` files in charts are **auto-generated** by helm-docs — do not edit them manually; edit `values.yaml` comments or `Chart.yaml` description instead
- Example charts pin their dependency on `common` — update both `Chart.yaml` version and run `helm dependency update` when changing
- The chart supports both Deployment and CronJob workloads (mutually exclusive via `deployment.enabled` / `cron.enabled`)
- Fixture values in `fixture/helm/` are used for CI template rendering validation
