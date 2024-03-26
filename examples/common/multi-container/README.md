# multi-container

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for multiple containers

## Requirements

| Repository                          | Name   | Version |
| ----------------------------------- | ------ | ------- |
| https://entur.github.io/helm-charts | common | 1.18.2  |

## Values

| Key                                                  | Type   | Default                         | Description |
| ---------------------------------------------------- | ------ | ------------------------------- | ----------- |
| common.app                                           | string | `"multi-container"`             |             |
| common.configmap.data.APP1CONF                       | string | `"yes"`                         |             |
| common.configmap.enabled                             | bool   | `true`                          |             |
| common.containers[0].cpu                             | float  | `1.1`                           |             |
| common.containers[0].cpuLimit                        | float  | `2`                             |             |
| common.containers[0].env[0].name                     | string | `"APP1"`                        |             |
| common.containers[0].env[0].value                    | string | `"something"`                   |             |
| common.containers[0].image                           | string | `"<+artifacts.primary.image>"`  |
| common.containers[0].memory                          | int    | `512`                           |             |
| common.containers[0].memoryLimit                     | int    | `1024`                          |             |
| common.containers[0].name                            | string | `"multi"`                       |             |
| common.containers[0].ports[0].containerPort          | int    | `9000`                          |             |
| common.containers[0].ports[0].name                   | string | `"http"`                        |             |
| common.containers[0].ports[0].protocol               | string | `"TCP"`                         |             |
| common.containers[0].ports[1].containerPort          | int    | `6001`                          |             |
| common.containers[0].ports[1].name                   | string | `"adm"`                         |             |
| common.containers[0].ports[1].protocol               | string | `"TCP"`                         |             |
| common.containers[0].probes.liveness.path            | string | `"/actuator/health/liveness"`   |             |
| common.containers[0].probes.readiness.path           | string | `"/actuator/health/readiness"`  |             |
| common.containers[0].probes.startup.failureThreshold | int    | `300`                           |             |
| common.containers[1].cpu                             | float  | `1.1`                           |             |
| common.containers[1].cpuLimit                        | float  | `2`                             |             |
| common.containers[1].image                           | string | `"yay"`                         |             |
| common.containers[1].memory                          | int    | `512`                           |             |
| common.containers[1].memoryLimit                     | int    | `1024`                          |             |
| common.containers[1].name                            | string | `"other"`                       |             |
| common.containers[1].probes.liveness.path            | string | `"/actuator/health/liveness"`   |             |
| common.containers[1].probes.readiness.path           | string | `"/actuator/health/readiness"`  |             |
| common.containers[1].probes.startup.failureThreshold | int    | `300`                           |             |
| common.deployment.prometheus.enabled                 | bool   | `true`                          |             |
| common.deployment.prometheus.path                    | string | `"/prom"`                       |             |
| common.deployment.prometheus.port                    | int    | `666`                           |             |
| common.env                                           | string | `"dev"`                         |             |
| common.ingress.enabled                               | bool   | `true`                          |             |
| common.ingress.trafficType                           | string | `"public"`                      |             |
| common.secrets.auth-credentials[0]                   | string | `"MNG_AUTH0_INT_CLIENT_ID"`     |             |
| common.secrets.auth-credentials[1]                   | string | `"MNG_AUTH0_INT_CLIENT_SECRET"` |             |
| common.service.internalPort                          | int    | `9000`                          |             |
| common.service.ports[0].port                         | int    | `80`                            |             |
| common.service.ports[0].protocol                     | string | `"TCP"`                         |             |
| common.service.ports[0].targetPort                   | int    | `9000`                          |             |
| common.service.ports[1].port                         | int    | `5001`                          |             |
| common.service.ports[1].protocol                     | string | `"TCP"`                         |             |
| common.service.ports[1].targetPort                   | int    | `6001`                          |             |
| common.shortname                                     | string | `"multcont"`                    |             |
| common.team                                          | string | `"example"`                     |             |

---

Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
