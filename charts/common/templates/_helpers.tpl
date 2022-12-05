{{- define "labels" }}
app: {{ .Release.Name }}
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
        app: {{ .Release.Name }}
  - maxSkew: 5
    topologyKey: "topology.kubernetes.io/zone"
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app: {{ .Release.Name }}
{{- end }}

{{- define "resources" }}
resources:
  limits:
    {{- if .cpuLimit }}
    cpu: {{ .cpuLimit }}
    {{- else }}
    cpu: "{{ printf "%.2f" .cpu | replace "0." "" | replace "." "" | int64 | mul 50 }}m"
    {{- end }}
    {{- if .memoryLimit }}
    memory: "{{ .memoryLimit }}Mi"
    {{- else }}
    memory: "{{ (div (mul .memory 6) 5) }}Mi"
    {{- end }}
  requests:
    cpu: {{ .cpu | float64 }}
    memory: "{{ .memory }}Mi"
{{- end }}

{{- define "environment" }}
{{- if .env }}
env:
  {{- toYaml .env | nindent 2 }}
{{ end }}
{{- if or .envFrom .configmap.enabled .postgres.enabled }}
envFrom:
  {{- if .envFrom }}
  {{- toYaml .envFrom | nindent 2 }}
  {{- end }}
  {{- if .configmap.enabled }}
  - configMapRef:
      name: {{ .Release.Name }}
  {{- end }}
  {{- if .postgres.enabled }}
  - secretRef:
      name: {{ .app }}-psql-credentials
  {{- end }}
{{- end }}
{{ end }}

{{- define "probes" }}
livenessProbe:
  httpGet:
    path: {{ .probes.liveness.path }}
    port: {{ .probes.liveness.port | default .internalPort }}
  failureThreshold: {{ .probes.liveness.failureThreshold | default 6 }}
  periodSeconds: {{ .probes.liveness.periodSeconds | default 5 }}
readinessProbe:
  httpGet:
    path: {{ .probes.readiness.path }}
    port: {{ .probes.readiness.port | default .internalPort }}
  failureThreshold: {{ .probes.liveness.failureThreshold | default 6 }}
  periodSeconds: {{ .probes.liveness.periodSeconds | default 5 }}
startupProbe:
  tcpSocket:
    port: {{ .probes.startup.port | default .internalPort }}
  failureThreshold: {{ .probes.startup.failureThreshold | default 300  }}
  periodSeconds: {{ .probes.startup.periodSeconds | default 1 }}
{{- end }}

{{- define "grpcprobes" }}
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
  image: gcr.io/cloudsql-docker/gce-proxy:1.30.1
  command:
    - "/cloud_sql_proxy"
    - "-verbose=false"
    - "-log_debug_stdout"
    - "-term_timeout=30s"
  envFrom:
  - configMapRef:
      name: {{ .app }}-psql-connection
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
      cpu: {{ .postgres.cpuLimit }}
      {{- else }}
      cpu: {{ .postgres.cpu }}
      {{- end }}
      memory: "{{ .postgres.memory }}Mi"
    requests:
      cpu: {{ .postgres.cpu }}
      memory: "{{ .postgres.memory }}Mi"
{{- end }}
