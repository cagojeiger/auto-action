{{/*
Expand the name of the chart.
*/}}
{{- define "argocd-pj.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argocd-pj.fullname" -}}
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
{{- define "argocd-pj.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "argocd-pj.labels" -}}
helm.sh/chart: {{ include "argocd-pj.chart" . }}
{{ include "argocd-pj.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argocd-pj.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argocd-pj.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create Docker config JSON for registry authentication
*/}}
{{- define "argocd-pj.dockerconfig" -}}
{{- $url := .url -}}
{{- $username := .username -}}
{{- $password := .password -}}
{{- $auth := printf "%s:%s" $username $password | b64enc -}}
{
  "auths": {
    "{{ $url }}": {
      "username": "{{ $username }}",
      "password": "{{ $password }}",
      "auth": "{{ $auth }}"
    }
  }
}
{{- end }}

{{/*
Detect repository type from URL
*/}}
{{- define "argocd-pj.detectRepoType" -}}
{{- $url := . -}}
{{- if hasPrefix "oci://" $url -}}
helm-oci
{{- else if hasPrefix "docker://" $url -}}
docker
{{- else if or (contains "github.com" $url) (contains "gitlab.com" $url) (contains "bitbucket.org" $url) (contains ".git" $url) -}}
git
{{- else if or (contains "index.docker.io" $url) (contains "ghcr.io" $url) (contains "quay.io" $url) (contains "gcr.io" $url) (contains "registry" $url) -}}
docker
{{- else if contains "charts" $url -}}
helm
{{- else -}}
git
{{- end -}}
{{- end }}

{{/*
Clean OCI URL (remove oci:// prefix for ArgoCD)
*/}}
{{- define "argocd-pj.cleanOciUrl" -}}
{{- if hasPrefix "oci://" . -}}
{{- trimPrefix "oci://" . -}}
{{- else -}}
{{- . -}}
{{- end -}}
{{- end }}