# Multi Deployment

This example shows how to create two deployments with the common chart.

Please take note of the use of `alias` in [Chart.yaml](./Chart.yaml):


```yaml
dependencies:
  - name: common
    version: ...
    repository: "https://entur.github.io/helm-charts"
    alias: multi-1
  - name: common
    version: ...
    repository: "https://entur.github.io/helm-charts"
    alias: multi-2
```

Now, we can configure two deployments in our [values.yaml](./values.yaml):

It is important to assign `releaseName` or else it will not work.

```yaml
multi-1:
  app: multi-1
  shortname: mult1
  team: example
  env: dev
  releaseName: multi1
  container:
    image: ${artifact.metadata.image}
    env:
      - name: APP1
        value: something
  configmap:
    enabled: true
    data:
      APP1CONF: yes
multi-2:
  app: multi-2
  shortname: mult2
  team: example
  env: dev
  releaseName: multi2
  container:
    image: ${artifact.metadata.image}
    env:
      - name: APP2
        value: somethingelse
  configmap:
    enabled: true
    data:
      APP2CONF: yes

```
