# Contributing to the Entur Helm Common Charts

Entur Helm Charts is a collection of a few opinionated helm charts used internally at Entur. To contribute to this repository follow this documentation.

## Documentation

### [common](./charts/common/README.md)

The common helm chart is a quick and easy way to get an application ready for deployment to a modern and secure cluster.
Read more in its updated [README.md](./charts/common/README.md).

#### Use [common](./charts/common/README.md)

Add to Chart.yaml:

```yaml
dependencies:
  - name: common
    version: <x.x.x>
    repository: "https://entur.github.io/helm-charts"
```

#### Update [common](./charts/common/README.md)

Update version in Chart.yaml and run `helm dependency update`

## Development

After changes do the following to verify that all possible outcomes is working as it should.

### Install helm chart unit test plugin and run unit tests

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest.git
helm unittest ./charts/common
```

### Update `values.schema.json` [JSON schema](https://json-schema.org/learn) if needed

The `values.schema.json` file is used to validate the values files. You need to update it if you add new values or change existing ones.

### Render test values files

Verify that the test value files generate ok

```bash
helm template charts/common -f fixture/helm//values-minimal.yaml
helm template charts/common -f fixture/helm//values-cron.yaml
helm template charts/common -f fixture/helm/values-secrets.yaml
helm template charts/common -f fixture/helm/values-postgres.yaml
```

### Update and Generate documentation

```bash
brew install norwoodj/tap/helm-docs
helm-docs
```

### Use conventional commits

<https://www.conventionalcommits.org/en/v1.0.0/>

TLDR:

- `feat!:` indicates a breaking change and a major upgrade, from 1.1.0 to 2.0.0
- `feat:` makes a minor upgrade, from 1.1.0 to 1.2.0
- `fix:` will patch from 1.1.0 to 1.1.1
- `docs:` or `ci:` skips upgrade
