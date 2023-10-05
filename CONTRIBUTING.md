# Contributin to Entur Helm Common Charts

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

### Render test values files

Verify that the test value files generate ok

```bash
helm template charts/common -f tests/values-minimal.yaml
helm template charts/common -f tests/values-cron.yaml
helm template charts/common -f tests/values-secrets.yaml
```

### Update and Generate documentation

```bash
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
```

### Install helm chart unit test plugin

```bash
helm plugin install https://github.com/helm-unittest/helm-unittest.git
```

### Run unit tests

```bash
helm unittest ./charts/common
```
