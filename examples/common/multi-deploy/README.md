# multi-deploy

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for basic Entur deployments

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://entur.github.io/helm-charts | multi-1(common) | 1.17.3 |
| https://entur.github.io/helm-charts | multi-2(common) | 1.17.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| multi-1.app | string | `"multi-1"` |  |
| multi-1.configmap.data.APP1CONF | string | `"yes"` |  |
| multi-1.configmap.enabled | bool | `true` |  |
| multi-1.container.image | string | `"${artifact.metadata.image}"` |  |
| multi-1.env | string | `"dev"` |  |
| multi-1.ingress.enabled | bool | `true` |  |
| multi-1.ingress.trafficType | string | `"public"` |  |
| multi-1.releaseName | string | `"multi1"` |  |
| multi-1.secrets.auth-credentials[0] | string | `"MNG_AUTH0_INT_CLIENT_ID"` |  |
| multi-1.secrets.auth-credentials[1] | string | `"MNG_AUTH0_INT_CLIENT_SECRET"` |  |
| multi-1.service.internalPort | int | `9000` |  |
| multi-1.shortname | string | `"mult1"` |  |
| multi-1.team | string | `"example"` |  |
| multi-2.app | string | `"multi-2"` |  |
| multi-2.configmap.data.APP2CONF | string | `"yes"` |  |
| multi-2.configmap.enabled | bool | `true` |  |
| multi-2.container.image | string | `"${artifact.metadata.image}"` |  |
| multi-2.env | string | `"dev"` |  |
| multi-2.ingress.enabled | bool | `true` |  |
| multi-2.ingress.trafficType | string | `"public"` |  |
| multi-2.releaseName | string | `"multi2"` |  |
| multi-2.secrets.auth-credentials[0] | string | `"MNG_AUTH0_INT_CLIENT_ID"` |  |
| multi-2.secrets.auth-credentials[1] | string | `"MNG_AUTH0_INT_CLIENT_SECRET"` |  |
| multi-2.service.internalPort | int | `9000` |  |
| multi-2.shortname | string | `"mult2"` |  |
| multi-2.team | string | `"example"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.2](https://github.com/norwoodj/helm-docs/releases/v1.11.2)