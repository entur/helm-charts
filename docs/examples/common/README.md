# README #

A few examples of how to use our [common](https://github.com/entur/helm-charts/tree/main/charts/common) chart.

If you are migrating from an old chart, please consider using [helm-migrate](https://bitbucket.org/enturas/helm-migrate) for a kickstart of your new chart!

For a manual start, please make sure you Chart.yaml uses `apiVersion: v2` and that it has requirements. See sample below:

    apiVersion: v2
    name: your-app
    description: Lorem
    version: 0.0.3
    keywords:
    - your-app
    sources:
    - https://bitbucket.org/enturas/your-app
    maintainers:
    - name: Team maeT
      email: tenet@entur.org
    engine: gotpl
    dependencies:
      - name: common
        version: 1.0.2
        repository: "https://entur.github.io/helm-charts" 

Now, for the initial setup, please run `helm dependency build helm/your-app` and replace `your-app` with your chart name.
From now on, Renovate Bot should notify you when there's a new chart ready for use. 
The PR will contain release notes and inform you of any breaking changes (will be very _very_ rare!).

Test it with `helm template helm/your-app -f helm/your-app/values-kub-ent-dev.yaml`.

## simple-app

This is a very simple application, a minimal use-case of this chart.
A good example for applications that simply require a few environment variables set per cluster.

[Read more](simple-app/README.md)

## typical-frontend

This example showcases a few things.

* Accept a `serviceVariable` from Harness as environment variable.
* Load a secret to the environment for all clusters
* Override a config map per cluster

[Read more](typical-frontend/README.md)

## typical-backend

Same as `typical-frontend` but with postgres!

[Read more](typical-backend/README.md)
