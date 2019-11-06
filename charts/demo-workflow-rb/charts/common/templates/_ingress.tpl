{{/* vim: set filetype=mustache: */}}
{{/*
Create a default tls secret name.
*/}}
{{- define "common.ingress-tlssecretname" -}}
	{{- $common := dict "Values" .Values.common -}} 
	{{- $noCommon := omit .Values "common" -}} 
	{{- $overrides := dict "Values" $noCommon -}} 
	{{- $noValues := omit . "Values" -}} 
	{{- with merge $noValues $overrides $common -}}
		{{- $tlsacmename := include "common.tlsacme-secretname" . -}}
		{{- $tlssecretname := default $tlsacmename .Values.ingress.tlsSecret -}}
		{{- tpl (printf "%s" $tlssecretname) $ | trunc 48 | trimSuffix "-" -}}
	{{- end -}}
{{- end -}}

{{- define "common.tlsacme-secretname" -}}
	{{- if include "common.tlsacme-enabled" . -}}
		{{- printf "tls-%s-%s" .Release.Name .Chart.Name -}}
	{{- else -}}
		{{- printf "" -}}
	{{- end -}}
{{- end -}}

{{/*
Create a default ingress host.
*/}}
{{- define "common.ingress-host" -}}
	{{- $common := dict "Values" .Values.common -}} 
	{{- $noCommon := omit .Values "common" -}} 
	{{- $overrides := dict "Values" $noCommon -}} 
	{{- $noValues := omit . "Values" -}} 
	{{- with merge $noValues $overrides $common -}}
		{{- $ingressHost := default (include "common.gateway-host" .) .Values.ingress.hostName -}}
		{{- tpl (printf "%s" $ingressHost) . -}}
	{{- end -}}
{{- end -}}

{{/*
Create a default ingress path.
*/}}
{{- define "common.ingress-path" -}}
	{{- $common := dict "Values" .Values.common -}} 
	{{- $noCommon := omit .Values "common" -}} 
	{{- $overrides := dict "Values" $noCommon -}} 
	{{- $noValues := omit . "Values" -}} 
	{{- with merge $noValues $overrides $common -}}
		{{- $value := default "" .Values.ingress.path -}}
		{{- tpl (printf "%s" $value) . -}}
	{{- end -}}
{{- end -}}

{{/*
Create a default ingress tls.
*/}}
{{- define "common.ingress-tls" -}}
	{{- $common := dict "Values" .Values.common -}} 
	{{- $noCommon := omit .Values "common" -}} 
	{{- $overrides := dict "Values" $noCommon -}} 
	{{- $noValues := omit . "Values" -}} 
	{{- with merge $noValues $overrides $common -}}
		{{- $tlsacme := include "common.tlsacme-enabled" . -}}
		{{- $tls := toString .Values.ingress.tls -}}
		{{- default "" (or (eq $tlsacme "true") (eq $tls "true")) -}}
	{{- end -}}
{{- end -}}

{{/*
Create default ingress annotations
*/}}
{{- define "common.ingress-annotations" -}}
{{- $common := dict "Values" .Values.common -}} 
{{- $noCommon := omit .Values "common" -}} 
{{- $overrides := dict "Values" $noCommon -}} 
{{- $noValues := omit . "Values" -}} 
{{- $values := merge $noValues $overrides $common -}} 
{{- with $values -}}

{{- range $key, $value := .Values.global.gateway.annotations }}
{{ $key }}: {{ tpl (printf "%s" $value) $values | quote }}
{{- end }}
{{- range $key, $value := .Values.ingress.annotations }}
{{- if (ne (toString $value) "null") }}
{{ $key }}: {{ tpl (printf "%s" $value) $values | quote }}
{{- end }}
{{- end }}

{{- if include "common.tlsacme-enabled" . }}
{{ "kubernetes.io/tls-acme" }}: {{ include "common.tlsacme-enabled" . | quote }}
{{- end }}

{{- end }}
{{- end -}}

{{/*
Default tlsacme-enabled template
*/}}
{{- define "common.tlsacme-enabled" -}}
	{{- $http := tpl (toString .Values.global.gateway.http) . -}}
	{{- $tlsacme := tpl (toString .Values.global.gateway.tlsacme) . -}}
	{{- default "" (and (eq $tlsacme "true") (eq $http "false")) -}}
{{- end -}}

