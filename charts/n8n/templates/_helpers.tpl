{{- define "n8n.fullname" -}}
{{- printf "%s-%s" .Release.Name "n8n" | trunc 63 | trimSuffix "-" -}}
{{- end -}}