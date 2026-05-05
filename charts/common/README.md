# common

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for Entur's Kubernetes workloads

## Highlighted features

* Defaults typically match a properly configured Spring Boot project
* Automatic HA with HPA and PDB in all environments (minReplicas: 2 by default)
* Enforces explicit setting of important aspects such as traffic type
* Rule based safety net, a chart that breaks business rules will fail with a helpful message
* JSON Schema validation catches typos and unknown properties on `helm lint`
* Compatible with Helm 3 and Helm 4

## Take full control

* Most properties can be overridden to your specific needs.
* Read the values.yaml file to get template documentation.
* See [UPGRADE.md](../../UPGRADE.md) for migration guides between major versions.
### Fully customize `container.probes.spec` and `hpa.spec` with literal Kubernetes configuration
<details>

  <summary>Example container.probes.spec</summary>

```yaml
common:
  container:
    probes:
      enabled: true
      spec:
        startupProbe:
          tcpSocket:
            port: 3000
          periodSeconds: 1
          timeoutSeconds: 1
          failureThreshold: 300
        livenessProbe: ...
        readinessProbe: ...
```
</details>
<details>

  <summary>Example hpa.spec</summary>

```yaml
common:
  hpa:
    spec:
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 60
      behavior:
        scaleUp:
          stabilizationWindowSeconds: 60
          policies:
            - type: Pods
              value: 1
              periodSeconds: 60
      maxReplicas: 7
      minReplicas: 2

```
</details>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| app | string | `nil` | Application name, typically on the form `the-application` |
| appId | string | `nil` | App ID from GoogleCloudApplication `metadata.id`. Max 10 alphanumeric characters. See https://github.com/entur/tf-gcp-apps/blob/main/docs/manifests/GoogleCloudApplication.md |
| configmap.data | object | `{}` | Set data for configmap |
| configmap.enabled | bool | false | Enable or disable the configmap |
| container.args | string | `nil` | Optionally set the arguments that will be passed to the command, e.g. ["arg1","arg2"]. |
| container.command | string | `nil` | Optionally set the command that will run in the pod. If not set, the entrypoint for the container-image is used (recommended for most Java-apps). |
| container.cpu | float | 0.3 | Set CPU request without any unit. 100m is 0.1. Default is sized for JVM/Spring Boot apps; lighter workloads (sidecars, small Go services, static frontends) should override down. |
| container.cpuLimit | float | `5 x cpu` | Set CPU limit without any unit. 100m is 0.1 |
| container.env | list | `[]` | Specify `env` entries for your container |
| container.envFrom | list | `[]` | Attach secrets and configmaps to your `env` |
| container.labels | object | `{}` | Add labels to your pods |
| container.lifecycle | object | `{}` | Set pod lifecycle handlers |
| container.memory | int | 512 | Set memory request without any unit, `Mi` is inferred. Memory limit always equals request. Default is sized for JVM/Spring Boot apps (the JVM alone needs ~150–250 MiB before app code runs); lighter workloads should override down. |
| container.memoryLimit | string | `nil` | @deprecated memoryLimit is removed. Memory limit is now always equal to memory request. Use `container.memory` instead. |
| container.name | string | .app | Name of container |
| container.probes.enabled | bool | `true` | Enable or disable probes |
| container.probes.liveness.failureThreshold | int | 6 | Set the failure threshold |
| container.probes.liveness.grpc | string | `nil` | Specify grpc probes for a port. Needs `port` child stanza |
| container.probes.liveness.initialDelaySeconds | int | `0` | Set the initial delay for the probe |
| container.probes.liveness.path | string | /actuator/health/liveness | Set the path for liveness probe |
| container.probes.liveness.periodSeconds | int | 5 | Set the period of checking |
| container.probes.liveness.successThreshold | int | 1 | Set the success threshold |
| container.probes.readiness.failureThreshold | int | 6 | Set the failure threshold |
| container.probes.readiness.grpc | string | `nil` | Specify grpc probes for a port. Needs `port` child stanza |
| container.probes.readiness.initialDelaySeconds | int | `0` | Set the initial delay for the probe |
| container.probes.readiness.path | string | /actuator/health/readiness | Set the path for readiness probe |
| container.probes.readiness.periodSeconds | int | 5 | Set the period of checking |
| container.probes.readiness.successThreshold | int | 1 | Set the success threshold |
| container.probes.spec | string | `nil` | Override with k8s spec for custom probes |
| container.probes.startup.failureThreshold | int | 300 | Set the failure threshold |
| container.probes.startup.grpc | string | `nil` | Specify grpc probes for a port. Needs `port` child stanza |
| container.probes.startup.path | string | `nil` | Set the path for startup probe. If set, uses httpGet instead of tcpSocket. Useful when startup includes long-running tasks like cache warming. |
| container.probes.startup.periodSeconds | int | 1 | Set the period of checking |
| container.prometheus.enabled | bool | `false` | Enable or disable Prometheus |
| container.prometheus.path | string | /actuator/prometheus | Set the path for scraping metrics |
| container.prometheus.port | int | service.internalPort | Set the port for prometheus scraping |
| container.uid | int | 1000 | Set the uid that your user runs with |
| container.volumeMounts | list | `[]` | Configure volume mounts, accepts kubernetes syntax |
| container.volumes | list | `[]` | Configure volume, accepts kubernetes syntax |
| containers | list | `[]` | Takes a list of `container` entries, you must add a `name` field for each entry |
| cron.activeDeadlineSeconds | int | `nil` | Active deadline seconds for the job, default 24 hours (86300s) |
| cron.concurrencyPolicy | string | Forbid | Concurrency policy |
| cron.enabled | bool | `false` | Enable or disable the cron job |
| cron.failedJobsHistoryLimit | int | 1 | Failed jobs history limit |
| cron.labels | object | `{}` | Add labels to your pods |
| cron.restartPolicy | string | OnFailure | Override pod restartPolicy (default OnFailure). |
| cron.schedule | string | `nil` | Required crontab schedule `* * * * * *` |
| cron.serviceAccountName | string | application | Override pod serviceAccountName (default application). |
| cron.successfulJobsHistoryLimit | int | 1 | Successful jobs history limit |
| cron.suspend | string | false | Suspend flag |
| cron.terminationGracePeriodSeconds | int | false | Override pod terminationGracePeriodSeconds (default 30s). |
| cron.volumes | list | `[]` | Configure volume, accepts kubernetes syntax |
| deployment.cpuUtilization | string | 70 | Set the target CPU average utilization (%) for HPA scaling. With startupCPUBoost enabled, 70% is a good default. Without it, 100% may be needed for Java apps with heavy startup CPU usage. |
| deployment.enabled | bool | `true` | Enable or disable the deployment |
| deployment.forceReplicas | int | `nil` | Force a fixed replica count, disables HPA and PDB. If set to 1 it will use Recreate strategy. |
| deployment.labels | object | `{}` | Add labels to your pods |
| deployment.maxReplicas | int | 10 | Set the max replica count for HPA |
| deployment.maxSurge | string | 1 | Limit max surge for rolling updates. Accepts an integer (pod count) or a string percentage (e.g. "25%"). Not in use when using forceReplicas. |
| deployment.maxUnavailable | string | 1 | Limit max unavailable for rolling updates. Accepts an integer (pod count) or a string percentage (e.g. "25%"). Not in use when using forceReplicas. |
| deployment.minAvailable | string | 50% | Set minimum available % for PDB |
| deployment.minReadySeconds | int | 0 | See https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds |
| deployment.minReplicas | int | 2 | Set the minimum replica count for HPA. |
| deployment.serviceAccountName | string | application | Override pod serviceAccountName (default application). |
| deployment.startupCPUBoost.enabled | bool | `false` | Enable GKE Startup CPU Boost to temporarily increase CPU during pod startup. Requires the kube-startup-cpu-boost operator installed in the cluster. Boost is reverted when the pod becomes Ready. When enabled, a CPU limit of 1.3x the CPU request is automatically set (unless `container.cpuLimit` is explicitly configured). |
| deployment.startupCPUBoost.percentageIncrease | int | 50 | Percentage to increase CPU requests during startup |
| deployment.terminationGracePeriodSeconds | int | `nil` | Override pod terminationGracePeriodSeconds (default 30s). |
| deployment.volumes | list | `[]` | Configure volume, accepts kubernetes syntax |
| env | string | `nil` | The current env, override in your `values-kub-ent-$env.yaml` files to `dev`, `tst` or `prd` |
| grpc | bool | `false` | Enable gRPC which will add an annotation and use grpc probes |
| hpa.metrics | list | [] | Additional HPA metrics appended alongside the default CPU metric. Accepts standard `autoscaling/v2` metric entries (Pods, Object, External). Use for scaling on custom metrics from Cloud Monitoring, Prometheus (GMP), or Pub/Sub. When multiple metrics are specified, HPA picks the one demanding the most replicas. |
| hpa.spec | object | `{}` | Full custom spec for HPA, replaces default metrics and min/max replicas. Inherits `scaleTargetRef`. |
| hpa.stabilizationWindowSeconds | int | 120 | Seconds to wait before scaling up after a metric spike. Only applied when startupCPUBoost is disabled, to avoid scaling on startup CPU spikes. Tune this to match your application's typical startup time (e.g. 60s for a fast app, 300s for a heavy Spring Boot app with cache warming). |
| ingress.annotations | object | `{}` | Optionally set annotations for the ingress |
| ingress.enabled | bool | `true` | Enable or disable the ingress |
| ingress.host | string | `nil` | Set the host name, do this in your `values-kub-ent-$env.yaml` files |
| ingress.ingressClassName | string | traefik | Set the IngressClass name. Uses `spec.ingressClassName` (replaces the deprecated `kubernetes.io/ingress.class` annotation). |
| ingress.trafficType | string | `nil` | Set the traffic type (`api`,`public` or `http2` for gRPC). Note: changing this value will cause a couple of minutes of downtime while the ingress controller reconciles. |
| ingresses | list | `[]` | Specify a list of `ingress` specs |
| initContainers | list | `[]` | See: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ |
| labels | object | `{ app shortname team common:version environment }` | Specify additional labels for every resource |
| pdb | object | `{}` |  |
| postgres.cpu | float | 0.05 | Configure cpu request for proxy |
| postgres.cpuLimit | float | `nil` | Configure optional cpu limit for proxy |
| postgres.credentialsSecret | string | `nil` | Override the Kubernetes secret name for credentials. Bypasses the ExternalSecret for credentials; the proxy ExternalSecret is still created. The secret must contain the expected env vars (e.g. `PGUSER`, `PGPASSWORD`). |
| postgres.enabled | bool | false | Enable or disable the Cloud SQL proxy v2 sidecar |
| postgres.instances | list | [] | List of database connections keyed by Terraform `secret_key_prefix`. Each entry derives Secret Manager keys: `{prefix}INSTANCES`, `{prefix}USER`, `{prefix}PASSWORD`. The chart generates `{prefix}HOST=localhost` and `{prefix}PORT=5432+index`. When empty and `enabled: true`, defaults to `[{secretKeyPrefix: PG}]`. |
| postgres.maxSigtermDelay | string | 30s | Override the max-sigterm-delay for the Cloud SQL Proxy. Adds a delay before the proxy begins shutdown after receiving SIGTERM, useful for allowing load balancers to deregister the pod. |
| postgres.memory | int | 16 | Configure memory request for proxy without units, `Mi` inferred |
| releaseName | string | `nil` | Override release name, useful for multiple deployments |
| secrets | object | `{}` | Add externalSecret to sync secrets from secret manager |
| service.annotations | object | `{}` | Optionally set annotations for the service |
| service.enabled | bool | `true` | Enable or disable the service |
| service.externalPort | int | 80 | Set the external port for your service |
| service.internalPort | int | 8080 | Set the internal port for your service |
| team | string | `nil` | Your team name, without a `team-` prefix |
| vpa.enabled | bool | `true` | Enable Vertical Pod Autoscaler to get resource requirement and limit recommendations |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
