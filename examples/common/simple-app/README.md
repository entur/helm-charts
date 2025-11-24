# simpe-app

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for basic Entur deployments

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://entur.github.io/helm-charts | common | 1.21.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| common.app | string | `"simple-app"` |  |
| common.container.image | string | `"<+artifacts.primary.image>"` |  |
| common.ingress.trafficType | string | `"public"` |  |
| common.shortname | string | `"simapp"` |  |
| common.team | string | `"example"` |  |

