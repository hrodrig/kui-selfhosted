{{/*
Chart helpers for kui stack (kiko + kui).
*/}}
{{- define "kui-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kui-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "kui-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kui-stack.labels" -}}
helm.sh/chart: {{ include "kui-stack.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{- define "kui-stack.kiko.labels" -}}
{{ include "kui-stack.labels" . }}
app.kubernetes.io/name: kiko
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: collector
{{- end }}

{{- define "kui-stack.kui.labels" -}}
{{ include "kui-stack.labels" . }}
app.kubernetes.io/name: kui
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: dashboard
{{- end }}

{{- define "kui-stack.kiko.selectorLabels" -}}
app.kubernetes.io/name: kiko
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "kui-stack.kui.selectorLabels" -}}
app.kubernetes.io/name: kui
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "kui-stack.kiko.image" -}}
{{- printf "%s:%s" .Values.kiko.image.repository (.Values.kiko.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{- define "kui-stack.kui.image" -}}
{{- printf "%s:%s" .Values.kui.image.repository (.Values.kui.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{- define "kui-stack.secretName" -}}
{{- if .Values.secrets.existingSecret }}
{{- .Values.secrets.existingSecret }}
{{- else }}
{{- printf "%s-secrets" (include "kui-stack.fullname" .) }}
{{- end }}
{{- end }}

{{- define "kui-stack.kiko.fullname" -}}
{{- printf "%s-kiko" (include "kui-stack.fullname" .) }}
{{- end }}

{{- define "kui-stack.kui.fullname" -}}
{{- printf "%s-kui" (include "kui-stack.fullname" .) }}
{{- end }}

{{- define "kui-stack.kiko.serviceName" -}}
{{- include "kui-stack.kiko.fullname" . }}
{{- end }}
