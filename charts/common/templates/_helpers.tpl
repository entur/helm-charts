{{- define "name" -}}
{{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
{{- end -}}

{{- define "labels" }}
app: {{ empty .Values.releaseName | ternary .Release.Name .Values.releaseName }}
shortname: {{ .Values.shortname }}
team: {{ .Values.team }}
common: {{ .Chart.Version }}
environment: {{ .Values.env }}
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
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
{{- if .env }}
  {{- toYaml .env | nindent 2 }}
{{ else }}
  []
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
  tcpSocket:
    port: {{ .probes.startup.port | default .internalPort }}
  failureThreshold: {{ .probes.startup.failureThreshold | default 300  }}
  periodSeconds: {{ .probes.startup.periodSeconds | default 1 }}
{{- end }}

{{- define "grpcprobes" }}
startupProbe:
  grpc:
    port: {{ .probes.startup.grpc.port | default .internalPort }}
  initialDelaySeconds: 10
  failureThreshold: 30
  periodSeconds: 10
readinessProbe:
  grpc:
    port: {{ .probes.readiness.grpc.port | default .internalPort }}
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
livenessProbe:
  grpc:
    port: {{ .probes.liveness.grpc.port | default .internalPort }}
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
{{- end }}
{{- define "grpcexecprobes" }}
startupProbe:
  exec:
    command: ["/bin/grpc_health_probe", "-addr=:{{ .internalPort }}", "-service=ready"]
  initialDelaySeconds: 10
  failureThreshold: 30
  periodSeconds: 10
readinessProbe:
  exec:
    command: ["/bin/grpc_health_probe", "-addr=:{{ .internalPort }}", "-service=ready"]
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
livenessProbe:
  exec:
    command: ["/bin/grpc_health_probe", "-addr=:{{ .internalPort }}", "-service=health"]
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
{{- end }}

{{- define "gcloud_sql_proxy" }}
- name: "{{ .app }}-sql-proxy"
  image: gcr.io/cloudsql-docker/gce-proxy:1.33.2
  command:
    - "/cloud_sql_proxy"
    - "-verbose=false"
    - "-log_debug_stdout=true"
    - "-structured_logs=true"
    - "-term_timeout=30s"
  envFrom:
  - configMapRef:
  {{- if .postgres.connectionConfig }}
      name: {{ .postgres.connectionConfig }}
  {{- else }}
      name: {{ .app }}-psql-connection
  {{- end }}
  securityContext:
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: RuntimeDefault
  resources:
    limits:
      {{- if .postgres.cpuLimit }}
      cpu: "{{ .postgres.cpuLimit }}"
      {{- end }}
      {{- if .postgres.memoryLimt }}
      memory: "{{ .postgres.memoryLimit }}Mi"
      {{- else }}
      memory: "{{ .postgres.memory }}Mi"
      {{- end }}
    requests:
      cpu: "{{ .postgres.cpu }}"
      memory: "{{ .postgres.memory }}Mi"
{{- end }}
