# cronjob

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for Entur CronJob workloads (no Deployment, Service, or Ingress).

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://entur.github.io/helm-charts | common | 1.21.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| common.app | string | `"my-cronjob"` |  |
| common.container.image | string | `"<+artifacts.primary.image>"` |  |
| common.cron.enabled | bool | `true` |  |
| common.cron.schedule | string | `"0 */6 * * *"` | Runs every 6 hours |
| common.deployment.enabled | bool | `false` |  |
| common.ingress.enabled | bool | `false` |  |
| common.service.enabled | bool | `false` |  |
| common.shortname | string | `"mycron"` |  |
| common.team | string | `"example"` |  |
