{{/*
  ops-stack chart용 fullname 헬퍼
  - fullnameOverride가 있으면 우선 사용
  - nameOverride가 있으면 차트 이름 대신 사용
  - 63자 제한 및 하이픈 트림
*/}}
{{- define "ops-stack.fullname" -}}
{{- if .Values.fullnameOverride | default "" -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.nameOverride | default .Chart.Name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
  ops-stack chart용 labels 헬퍼
  - app.kubernetes.io 표준 라벨 사용
*/}}
{{- define "ops-stack.labels" -}}
app.kubernetes.io/name: {{ include "ops-stack.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}} 