{{/*
Expand the name of the chart.
*/}}
{{- define "quick-deploy.name" -}}
{{- default .name .app.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quick-deploy.fullname" -}}
{{- if .app.fullnameOverride }}
{{- .app.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .name .app.nameOverride }}
{{- if contains $name .root.Release.Name }}
{{- .root.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .root.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "quick-deploy.chart" -}}
{{- printf "%s-%s" .root.Chart.Name .root.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quick-deploy.labels" -}}
helm.sh/chart: {{ include "quick-deploy.chart" . }}
{{ include "quick-deploy.selectorLabels" . }}
{{- if .root.Chart.AppVersion }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quick-deploy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quick-deploy.name" . }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quick-deploy.serviceAccountName" -}}
{{- if .app.serviceAccount.create }}
{{- default (include "quick-deploy.fullname" .) .app.serviceAccount.name }}
{{- else }}
{{- default "default" .app.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate that Ingress and Istio are not both enabled for the same app
*/}}
{{- define "quick-deploy.validateIstio" -}}
{{- range $name, $app := .Values.apps }}
  {{- if and $app.ingress $app.ingress.enabled $app.istio $app.istio.enabled }}
    {{- fail (printf "App '%s': ingress and istio cannot both be enabled. Please choose one traffic management solution." $name) }}
  {{- end }}
{{- end }}
{{- end }}