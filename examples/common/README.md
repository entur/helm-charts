# Common Helm Chart Examples

A few examples of how to use our [common](https://github.com/entur/helm-charts/tree/main/charts/common) chart.

Please inspec the one closest to what you need.

## Quickstart

Fetch dependencies

```bash
helm dependency build
````

Template

```bash
helm template myapp . -f ./env/values-kub-ent-dev.yaml
```

Inspect results and make sure there's no errors.
