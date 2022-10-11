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

{{- define "gcloud_sql_proxy" }}
- name: "{{ .Values.app }}-sql-proxy"
  image: gcr.io/cloudsql-docker/gce-proxy:1.30.1
  command:
    - "/cloud_sql_proxy"
    - "-verbose=false"
    - "-log_debug_stdout"
    - "-term_timeout=30s"
  envFrom:
  - configMapRef:
      name: {{ .Values.app }}-psql-connection
  securityContext:
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: RuntimeDefault
  resources:
    limits:
      {{- if .Values.postgres.cpuLimit }}
      cpu: {{ .Values.postgres.cpuLimit }}
      {{- else }}
      cpu: {{ .Values.postgres.cpu }}
      {{- end }}
      {{- if .Values.postgres.memoryLimit }}
      memory: "{{ .Values.postgres.memoryLimit }}Mi"
      {{- else }}
      memory: "{{ .Values.postgres.memory }}Mi"
      {{- end }}
    requests:
      cpu: {{ .Values.postgres.cpu }}
      memory: "{{ .Values.postgres.memory }}Mi"
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
