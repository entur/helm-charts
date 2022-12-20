# Entur Helm Charts

Entur Helm Charts is a collection of a few opinionated helm charts used internally at Entur.

## Documentation

### [common](./charts/common/README.md)

The common helm chart is a quick and easy way to get an application ready for deployment to a modern and secure cluster.
Read more in its updated [README.md](./charts/common/README.md).

#### Use [common](./charts/common/README.md)
Add to Chart.yaml:

```yaml
dependencies:
  - name: common
    version: 1.3.1
    repository: "https://entur.github.io/helm-charts"
```

#### Update [common](./charts/common/README.md)  

Update version in Chart.yaml and run `helm dependency update`.

## Development

### Render example values files

```bash
helm template charts/common -f example/values-minimal.yaml
helm template charts/common -f example/values-cron.yaml
```

### Generate documentation

```bash
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
```
        
### Install helm chart unit test plugin

```bash
helm plugin install https://github.com/vbehar/helm3-unittest
```
        
### Run unit tests

```bash
helm unittest ./charts/common
```
