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
Deep merge two maps
*/}}
{{- define "template-deployment.deepMerge" -}}
{{- $top := first . -}}
{{- $overrides := last . -}}
{{- range $key, $value := $overrides -}}
  {{- if or (not (hasKey $top $key)) (not (kindIs "map" $value)) -}}
    {{- $_ := set $top $key $value -}}
  {{- else -}}
    {{- $_ := set $top $key (include "template-deployment.deepMerge" (list (get $top $key) $value) | fromYaml) -}}
  {{- end -}}
{{- end -}}
{{- $top | toYaml -}}
{{- end -}}

{{/*
Get template defaults based on type
*/}}
{{- define "template-deployment.getDefaults" -}}
{{- $type := .type | default "" -}}
{{- $defaults := dict -}}

{{/* appProfiles가 있는지 확인 */}}
{{- if .root.Values.appProfiles -}}
  {{/* 기본 템플릿 적용 (있는 경우) */}}
  {{- if hasKey .root.Values.appProfiles "default" -}}
    {{- $defaults = index .root.Values.appProfiles "default" -}}
  {{- end -}}

  {{- if $type -}}
    {{- if kindIs "string" $type -}}
      {{/* 단일 타입인 경우 */}}
      {{- if hasKey .root.Values.appProfiles $type -}}
        {{- $typeDefaults := index .root.Values.appProfiles $type -}}
        {{- $defaults = include "template-deployment.deepMerge" (list $defaults $typeDefaults) | fromYaml -}}
      {{- end -}}
    {{- else if kindIs "slice" $type -}}
      {{/* 여러 타입인 경우 - 리스트 역순으로 머지 (앞에 있는 타입이 우선순위 높음) */}}
      {{- $reversedTypes := list -}}
      {{- range $index, $t := $type -}}
        {{- $reversedTypes = prepend $reversedTypes $t -}}
      {{- end -}}
      {{- range $index, $t := $reversedTypes -}}
        {{- if hasKey $.root.Values.appProfiles $t -}}
          {{- $typeDefaults := index $.root.Values.appProfiles $t -}}
          {{- $defaults = include "template-deployment.deepMerge" (list $defaults $typeDefaults) | fromYaml -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $defaults | toYaml -}}
{{- end -}}

{{/*
Merge template values with defaults
*/}}
{{- define "template-deployment.mergeValues" -}}
{{- $defaults := include "template-deployment.getDefaults" . | fromYaml -}}
{{- $values := .values | deepCopy -}}
{{- $merged := include "template-deployment.deepMerge" (list $defaults $values) | fromYaml -}}
{{- $merged | toYaml -}}
{{- end -}}
