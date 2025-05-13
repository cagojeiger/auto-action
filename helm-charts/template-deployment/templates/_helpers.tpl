{{/*
Expand the name of the chart.
*/}}
{{- define "template-deployment.name" -}}
{{- default .values.name .values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "template-deployment.fullname" -}}
{{- if .values.fullnameOverride }}
{{- .values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .values.name .values.nameOverride }}
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
{{- define "template-deployment.chart" -}}
{{- printf "%s-%s" .root.Chart.Name .root.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "template-deployment.labels" -}}
helm.sh/chart: {{ include "template-deployment.chart" . }}
{{ include "template-deployment.selectorLabels" . }}
{{- if .root.Chart.AppVersion }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "template-deployment.selectorLabels" -}}
app.kubernetes.io/name: {{ include "template-deployment.name" . }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "template-deployment.serviceAccountName" -}}
{{- if .values.serviceAccount.create }}
{{- default (include "template-deployment.fullname" .) .values.serviceAccount.name }}
{{- else }}
{{- default "default" .values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get template defaults based on type
*/}}
{{- define "template-deployment.getDefaults" -}}
{{- $type := .type | default "" -}}
{{- if $type -}}
  {{- if hasKey .root.Values.templateDefaults $type -}}
    {{- index .root.Values.templateDefaults $type | toYaml -}}
  {{- else -}}
    {{- dict | toYaml -}}
  {{- end -}}
{{- else -}}
  {{- dict | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Merge template values with defaults
*/}}
{{- define "template-deployment.mergeValues" -}}
{{- $defaults := include "template-deployment.getDefaults" . | fromYaml -}}
{{- $values := .values | deepCopy -}}
{{- $merged := merge $values $defaults -}}
{{- $merged | toYaml -}}
{{- end -}}