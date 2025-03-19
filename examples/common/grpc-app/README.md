# grpc-app

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for basic Entur deployments using gRPC

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://entur.github.io/helm-charts | common | .. |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| common.app | string | `"grpc-app"` |  |
| common.container.image | string | `"<+artifacts.primary.image>"` |  |
| common.grpc | bool | `true` |  |
| common.ingress.enabled | bool | `true` |  |
| common.ingress.trafficType | string | `"http2"` |  |
| common.service.annotations."entur.no/internal-http2" | string | `"true"` |  |
| common.shortname | string | `"grpcapp"` |  |
| common.team | string | `"example"` |  |

