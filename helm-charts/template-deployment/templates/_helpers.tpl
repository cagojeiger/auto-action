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
Create a resource name with optional namespace awareness to prevent collisions
*/}}
{{- define "template-deployment.resourceName" -}}
{{- $name := include "template-deployment.fullname" . -}}
{{- $resourceType := .resourceType | default "" -}}
{{- if .values.namespace -}}
  {{- /* If namespace is provided, use it as prefix */}}
  {{- if $resourceType -}}
    {{- printf "%s-%s-%s" .values.namespace $name $resourceType | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" .values.namespace $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- else -}}
  {{- /* If namespace is not provided, don't use namespace prefix */}}
  {{- if $resourceType -}}
    {{- printf "%s-%s" $name $resourceType | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Deep merge two maps with optimized performance and error handling
*/}}
{{- define "template-deployment.deepMerge" -}}
{{- $top := first . -}}
{{- $overrides := last . -}}
{{- if not (kindIs "map" $top) -}}
  {{- fail (printf "Expected map for first argument, got %s" (kindOf $top)) -}}
{{- end -}}
{{- if not (kindIs "map" $overrides) -}}
  {{- fail (printf "Expected map for second argument, got %s" (kindOf $overrides)) -}}
{{- end -}}
{{- range $key, $value := $overrides -}}
  {{- if or (not (hasKey $top $key)) (not (kindIs "map" $value)) -}}
    {{- $_ := set $top $key $value -}}
  {{- else -}}
    {{- $topValue := get $top $key -}}
    {{- if kindIs "map" $topValue -}}
      {{- $merged := include "template-deployment.deepMerge" (list $topValue $value) -}}
      {{- if not $merged -}}
        {{- fail (printf "Failed to merge values for key %s" $key) -}}
      {{- end -}}
      {{- $_ := set $top $key ($merged | fromYaml) -}}
    {{- else -}}
      {{- $_ := set $top $key $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $top | toYaml -}}
{{- end -}}

{{/*
Get template defaults based on type with improved validation and documentation
*/}}
{{- define "template-deployment.getDefaults" -}}
{{- $type := .type | default "" -}}
{{- $defaults := dict -}}

{{/* Get defaults from templateDefaults */}}
{{- if .root.Values.templateDefaults -}}
  {{/* Apply global defaults first */}}
  {{- if hasKey .root.Values.templateDefaults "default" -}}
    {{- $defaults = index .root.Values.templateDefaults "default" -}}
  {{- end -}}

  {{- if $type -}}
    {{- if kindIs "string" $type -}}
      {{/* Single type inheritance */}}
      {{- if not (hasKey .root.Values.templateDefaults $type) -}}
        {{- if ne $type "default" -}}
          {{- printf "Warning: Type '%s' is not defined in templateDefaults" $type | fail -}}
        {{- end -}}
      {{- else -}}
        {{- $typeDefaults := index .root.Values.templateDefaults $type -}}
        {{- $defaults = include "template-deployment.deepMerge" (list $defaults $typeDefaults) | fromYaml -}}
      {{- end -}}
    {{- else if kindIs "slice" $type -}}
      {{/* Multiple type inheritance - applied in reverse order (last has highest precedence) */}}
      {{- $reversedTypes := list -}}
      {{- range $index, $t := $type -}}
        {{- $reversedTypes = prepend $reversedTypes $t -}}
      {{- end -}}
      {{- range $index, $t := $reversedTypes -}}
        {{- if not (hasKey $.root.Values.templateDefaults $t) -}}
          {{- if ne $t "default" -}}
            {{- printf "Warning: Type '%s' is not defined in templateDefaults" $t | fail -}}
          {{- end -}}
        {{- else -}}
          {{- $typeDefaults := index $.root.Values.templateDefaults $t -}}
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
