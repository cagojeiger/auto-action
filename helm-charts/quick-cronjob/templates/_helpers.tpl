{{/*
Expand the name of the chart.
*/}}
{{- define "quick-cronjob.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quick-cronjob.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "quick-cronjob.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quick-cronjob.labels" -}}
{{- $root := .root -}}
{{- $name := .name -}}
helm.sh/chart: {{ include "quick-cronjob.chart" $root }}
app.kubernetes.io/name: {{ include "quick-cronjob.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- if $name }}
app.kubernetes.io/component: {{ $name }}
{{- end }}
{{- if $root.Chart.AppVersion }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Release.Service }}
{{- end }}

{{/*
Full name for a job
*/}}
{{- define "quick-cronjob.jobFullname" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- printf "%s-%s" $root.Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
ServiceAccount name for a job
*/}}
{{- define "quick-cronjob.serviceAccountName" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $job := .job -}}
{{- if and $job.serviceAccount $job.serviceAccount.name -}}
{{- $job.serviceAccount.name -}}
{{- else -}}
{{- include "quick-cronjob.jobFullname" (dict "root" $root "name" $name) -}}
{{- end -}}
{{- end -}}

{{/*
ConfigMap name for a job
*/}}
{{- define "quick-cronjob.configMapName" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $job := .job -}}
{{- if and $job.configMap $job.configMap.name -}}
{{- $job.configMap.name -}}
{{- else -}}
{{- printf "%s-config" (include "quick-cronjob.jobFullname" (dict "root" $root "name" $name)) -}}
{{- end -}}
{{- end -}}

{{/*
PVC name for a job
*/}}
{{- define "quick-cronjob.pvcName" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $job := .job -}}
{{- if and $job.persistence $job.persistence.name -}}
{{- $job.persistence.name -}}
{{- else if and $job.persistence $job.persistence.existingClaim -}}
{{- $job.persistence.existingClaim -}}
{{- else -}}
{{- printf "%s-pvc" (include "quick-cronjob.jobFullname" (dict "root" $root "name" $name)) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "quick-cronjob.serviceAccount" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quick-cronjob.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image name for a job
*/}}
{{- define "quick-cronjob.image" -}}
{{- $root := .root -}}
{{- $job := .job -}}
{{- $registry := "" -}}
{{- if $root.Values.global.imageRegistry -}}
{{- $registry = printf "%s/" $root.Values.global.imageRegistry -}}
{{- end -}}
{{- printf "%s%s:%s" $registry $job.image.repository $job.image.tag -}}
{{- end -}}

{{/*
Timezone for a job
*/}}
{{- define "quick-cronjob.timeZone" -}}
{{- $root := .root -}}
{{- $job := .job -}}
{{- if $job.timeZone -}}
{{- $job.timeZone -}}
{{- else if $root.Values.global.timezone -}}
{{- $root.Values.global.timezone -}}
{{- else -}}
{{- "UTC" -}}
{{- end -}}
{{- end -}}