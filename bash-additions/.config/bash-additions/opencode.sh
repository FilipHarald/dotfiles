#!/bin/bash

# opencode telemetry via the tailnet OpenTelemetry Collector on angel_2.
OPENCODE_TELEMETRY_HOST="${OPENCODE_TELEMETRY_HOST:-$(hostname -s 2>/dev/null || hostname)}"

export OPENCODE_ENABLE_TELEMETRY=1
export OPENCODE_OTLP_ENDPOINT=http://angel-2.taila8aaf1.ts.net:4317
export OPENCODE_OTLP_PROTOCOL=grpc
export OPENCODE_RESOURCE_ATTRIBUTES="host.name=${OPENCODE_TELEMETRY_HOST},service.instance.id=${OPENCODE_TELEMETRY_HOST},deployment.environment=personal"

if [ -f "$HOME/.config/bash-additions/opencode-secrets.sh" ]; then
    source "$HOME/.config/bash-additions/opencode-secrets.sh"
fi
