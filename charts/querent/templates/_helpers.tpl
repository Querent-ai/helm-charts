{{/*
Expand the name of the chart.
*/}}
{{- define "querent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "querent.fullname" -}}
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
{{- define "querent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "querent.labels" -}}
helm.sh/chart: {{ include "querent.chart" . }}
{{ include "querent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "querent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "querent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Semantic Service Selector labels
*/}}
{{- define "querent.semantics.selectorLabels" -}}
{{ include "querent.selectorLabels" . }}
app.kubernetes.io/component: semantics
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "querent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "querent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
{{/*
Querent ports
*/}}
{{- define "querent.ports" -}}
- name: rest
  containerPort: 1111
  protocol: TCP
- name: discovery
  containerPort: 2222
  protocol: UDP
- name: grpc
  containerPort: 3333
  protocol: TCP
{{- end }}

{{/*
Querent environment
*/}}
{{- define "querent.environment" -}}
- name: NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: QUESTER_NODE_CONFIG
  value: /querent/node.yaml
- name: QUESTER_CLUSTER_ID
  value: {{ .Release.Namespace }}-{{ include "querent.fullname" . }}
- name: QUESTER_NODE_ID
  value: "$(POD_NAME)"
- name: QUESTER_PEER_SEEDS
  value: {{ include "querent.fullname" . }}-headless
- name: QUESTER_ADVERTISE_ADDRESS
  value: "$(POD_IP)"
{{- range $key, $value := .Values.environment }}
- name: "{{ $key }}"
  value: "{{ $value }}"
{{- end }}
{{- end }}
