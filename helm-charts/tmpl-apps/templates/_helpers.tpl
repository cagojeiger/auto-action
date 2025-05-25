{{/*
Expand the name of the chart.
*/}}
{{- define "tmpl-apps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "tmpl-apps.fullname" -}}
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
{{- define "tmpl-apps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tmpl-apps.labels" -}}
helm.sh/chart: {{ include "tmpl-apps.chart" .root }}
{{ include "tmpl-apps.selectorLabels" . }}
{{- if .root.Chart.AppVersion }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
{{- with .root.Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tmpl-apps.selectorLabels" -}}
app.kubernetes.io/name: {{ .app.name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tmpl-apps.serviceAccountName" -}}
{{- if and .app.serviceAccount .app.serviceAccount.create }}
{{- default (printf "%s-%s" (include "tmpl-apps.fullname" .root) .app.name) (.app.serviceAccount.name | default "") }}
{{- else if .app.serviceAccount }}
{{- default "default" .app.serviceAccount.name }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}

{{/*
Get app fullname
*/}}
{{- define "tmpl-apps.appFullname" -}}
{{- printf "%s-%s" (include "tmpl-apps.fullname" .root) .app.name }}
{{- end }}

{{/*
Merge profile with app configuration
*/}}
{{- define "tmpl-apps.mergeConfig" -}}
{{- $root := .root }}
{{- $app := .app }}
{{- $profileName := .app.profile | default "base" }}
{{- $profiles := .root.Values.profiles }}

{{/* Start with base profile if it exists */}}
{{- $merged := dict }}
{{- if hasKey $profiles "base" }}
{{- $merged = deepCopy $profiles.base }}
{{- end }}

{{/* Apply profile chain */}}
{{- $currentProfile := $profileName }}
{{- $visitedProfiles := list }}
{{- range $i := until 10 }}
  {{- if and (hasKey $profiles $currentProfile) (not (has $currentProfile $visitedProfiles)) }}
    {{- $profile := index $profiles $currentProfile }}
    {{- $merged = mergeOverwrite $merged (deepCopy $profile) }}
    {{- $visitedProfiles = append $visitedProfiles $currentProfile }}
    {{- if hasKey $profile "extends" }}
      {{- $currentProfile = $profile.extends }}
    {{- else }}
      {{- break }}
    {{- end }}
  {{- else }}
    {{- break }}
  {{- end }}
{{- end }}

{{/* Finally merge app-specific config */}}
{{- $merged = mergeOverwrite $merged (deepCopy $app) }}

{{/* Handle shortcuts */}}
{{- if hasKey $app "scale" }}
{{- $_ := set $merged "replicas" $app.scale }}
{{- end }}

{{- if hasKey $app "expose" }}
{{- if not (hasKey $merged "service") }}
{{- $_ := set $merged "service" dict }}
{{- end }}
{{- $_ := set $merged.service "port" $app.expose }}
{{- $_ := set $merged.service "enabled" true }}
{{- end }}

{{- if hasKey $app "host" }}
{{- if not (hasKey $merged "ingress") }}
{{- $_ := set $merged "ingress" dict }}
{{- end }}
{{- $host := $app.host }}
{{- if not (contains "." $host) }}
{{- $host = printf "%s.%s" $host $root.Values.global.domain }}
{{- end }}
{{- $_ := set $merged.ingress "host" $host }}
{{- $_ := set $merged.ingress "enabled" true }}
{{- end }}

{{- toYaml $merged }}
{{- end }}

{{/*
Get image with registry
*/}}
{{- define "tmpl-apps.image" -}}
{{- $image := .app.image }}
{{- if typeIs "string" $image }}
  {{- if .root.Values.global.imageRegistry }}
    {{- printf "%s/%s" .root.Values.global.imageRegistry $image }}
  {{- else }}
    {{- $image }}
  {{- end }}
{{- else }}
  {{- $registry := .root.Values.global.imageRegistry | default $image.registry }}
  {{- $repository := required "image.repository is required" $image.repository }}
  {{- $tag := $image.tag | default .root.Chart.AppVersion | toString }}
  {{- if $registry }}
    {{- printf "%s/%s:%s" $registry $repository $tag }}
  {{- else }}
    {{- printf "%s:%s" $repository $tag }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Generate container port
*/}}
{{- define "tmpl-apps.containerPort" -}}
{{- if .app.service.enabled }}
{{- .app.service.port | default 80 }}
{{- else }}
{{- 8080 }}
{{- end }}
{{- end }}