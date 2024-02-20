# Common Helm Chart Examples

A few examples of how to use our [common](https://github.com/entur/helm-charts/tree/main/charts/common) chart.

If you are migrating from an old chart, please consider using [helm-migrate](https://bitbucket.org/enturas/helm-migrate) for a kickstart of your new chart!

For a manual start, please make sure you Chart.yaml uses `apiVersion: v2` and that it has requirements. See sample below:

```yaml
apiVersion: v2
name: my-app
description: "My App Description"
version: 0.0.1
appVersion: 0.0.1
dependencies:
  - name: common
    version: 1.17.1
    repository: "https://entur.github.io/helm-charts"
```

Now, for the initial setup, please run `helm dependency build helm/your-app` and replace `your-app` with your chart name.
From now on, Renovate Bot should notify you when there's a new chart ready for use.
The PR will contain release notes and inform you of any breaking changes (will be very _very_ rare!).

Test it with `helm template helm/your-app -f helm/your-app/env/values-kub-ent-dev.yaml`.
