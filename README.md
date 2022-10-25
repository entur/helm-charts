# Entur Helm Charts

Entur Helm Charts is a collection of a few opinionated helm charts used internally at Entur.

## Documentation

### [common](./charts/common/README.md)

The common helm chart is a quick and easy way to get an application ready for deployment to a modern and secure cluster.
Read more in its updated [README.md](./charts/common/README.md).

## Development

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
