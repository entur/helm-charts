{{- define "name" -}}
{{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
{{- end -}}

{{- define "labels" }}
app: {{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
{{- if and (not .Values.appId) .Values.shortname }}
  {{- fail "shortname is deprecated. Use appId instead." }}
{{- end }}
appId: {{ .Values.appId }}
shortname: {{ .Values.appId }}
team: {{ .Values.team }}
common: {{ .Chart.Version }}
environment: {{ .Values.env }}
app.kubernetes.io/instance: {{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
app.kubernetes.io/managed-by: Helm
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end }}

{{- define "annotations" }}
meta.helm.sh/release-name: {{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
meta.helm.sh/release-namespace: {{ empty .Release.Namespace| ternary .Release.Name .Release.Namespace }}
{{- end }}



{{- define "securitycontext" }}
securityContext:
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
{{- end }}

{{- define "topologyspreadconstraints" }}
topologySpreadConstraints:
  - maxSkew: 3
    topologyKey: "kubernetes.io/hostname"
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app: {{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
  - maxSkew: 5
    topologyKey: "topology.kubernetes.io/zone"
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app: {{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
{{- end }}

{{- define "resources" }}
resources:
  limits:
    {{- if .cpuLimit }}
    cpu: "{{ .cpuLimit| float64 }}"
    {{- else if .startupCPUBoostEnabled }}
    {{- /* When CPU boost is enabled, set limit to 1.3x request so the boost operator has a ceiling to work within */}}
    cpu: "{{ printf "%.2f" (divf (mulf .cpu 13) 10) }}"
    {{- end }}
    {{- if .memoryLimit }}
    memory: "{{ .memoryLimit }}Mi"
    {{- else }}
    memory: "{{ (div (mul .memory 6) 5) }}Mi"
    {{- end }}
    {{- if .ephemeralStorageLimit }}
    ephemeral-storage: "{{ .ephemeralStorageLimit }}"
    {{- end }}
  requests:
    cpu: "{{ .cpu | float64 }}"
    memory: "{{ .memory }}Mi"
    {{- if .ephemeralStorage}}
    ephemeral-storage: "{{ .ephemeralStorage}}"
    {{- end }}
{{- end }}

{{- define "environment" }}
env:
  - name: COMMON_ENV
    value: {{ .envLabel }}
  {{- if .env }}
  {{- toYaml .env | nindent 2 }}
  {{ end }}
{{- if or .envFrom .configmap.enabled .postgres.enabled .secrets}}
envFrom:
  {{- if .envFrom }}
  {{- toYaml .envFrom | nindent 2 }}
  {{- end }}
  {{- if .configmap.enabled }}
  - configMapRef:
      name: {{ .releaseName }}
  {{- end }}
  {{- if .postgres.enabled }}
  - secretRef:
  {{- if .postgres.credentialsSecret }}
      name: {{ .postgres.credentialsSecret }}
  {{- else }}
      name: {{ .app }}-psql-credentials
  {{- end }}
  {{- end }}
  {{- if .secrets }}
  {{- range $secret, $secretValue := .secrets }}
  - secretRef:
      name: {{ $.releaseName }}-{{ $secret }}
  {{- end }}
  {{- end }}
{{- end }}
{{ end }}

{{- define "probes" }}
livenessProbe:
  httpGet:
    path: {{ .probes.liveness.path }}
    port: {{ .probes.liveness.port | default .internalPort }}
  initialDelaySeconds: {{ .probes.liveness.initialDelaySeconds | default 0 }}
  successThreshold: {{ .probes.liveness.successThreshold | default 1 }}
  failureThreshold: {{ .probes.liveness.failureThreshold | default 6 }}
  periodSeconds: {{ .probes.liveness.periodSeconds | default 5 }}
readinessProbe:
  httpGet:
    path: {{ .probes.readiness.path }}
    port: {{ .probes.readiness.port | default .internalPort }}
  initialDelaySeconds: {{ .probes.readiness.initialDelaySeconds | default 0 }}
  successThreshold: {{ .probes.readiness.successThreshold | default 1 }}
  failureThreshold: {{ .probes.readiness.failureThreshold | default 6 }}
  periodSeconds: {{ .probes.readiness.periodSeconds | default 5 }}
startupProbe:
  {{- if .probes.startup.path }}
  httpGet:
    path: {{ .probes.startup.path }}
    port: {{ .probes.startup.port | default .internalPort }}
  {{- else }}
  tcpSocket:
    port: {{ .probes.startup.port | default .internalPort }}
  {{- end }}
  failureThreshold: {{ .probes.startup.failureThreshold | default 300  }}
  periodSeconds: {{ .probes.startup.periodSeconds | default 1 }}
{{- end }}

{{- define "grpcprobes" }}
startupProbe:
  grpc:
    port: {{ ((.probes.startup).grpc).port | default .internalPort }}
  initialDelaySeconds: 10
  failureThreshold: 30
  periodSeconds: 10
readinessProbe:
  grpc:
    port: {{ ((.probes.readiness).grpc).port | default .internalPort }}
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
livenessProbe:
  grpc:
    port: {{ ((.probes.liveness).grpc).port | default .internalPort }}
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
{{- end }}
{{- define "gcloud_sql_proxy" }}
{{- if .postgres.connectionConfig }}
  {{- fail "postgres.connectionConfig is deprecated. Use postgres.instances instead. See migration guide for Cloud SQL Proxy v2." }}
{{- end }}
- name: "{{ .app }}-sql-proxy"
  image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.21.2
  command:
    - "/cloud-sql-proxy"
    - "--structured-logs"
    - "--max-sigterm-delay=30s"
    - "--http-port=9801"
    - "--prometheus"
  ports:
    - name: metrics
      containerPort: 9801
      protocol: TCP
  envFrom:
  - secretRef:
      name: {{ .releaseName }}-sql-proxy
  securityContext:
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: RuntimeDefault
  {{- if .postgres.memoryLimit }}
    {{- fail "postgres.memoryLimit is deprecated. Memory limit is now always equal to memory request. Remove memoryLimit and use postgres.memory instead." }}
  {{- end }}
  resources:
    limits:
      {{- if .postgres.cpuLimit }}
      cpu: "{{ .postgres.cpuLimit }}"
      {{- end }}
      memory: "{{ .postgres.memory }}Mi"
    requests:
      cpu: "{{ .postgres.cpu }}"
      memory: "{{ .postgres.memory }}Mi"
{{- end }}

{{- define "hpa.enabled" -}}
  {{- if and (not .forceReplicas) (or (eq "prd" .env) .maxReplicas .hpa.spec.minReplicas) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

