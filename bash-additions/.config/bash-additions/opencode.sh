#!/bin/bash

# opencode telemetry via the tailnet OpenTelemetry Collector on angel_2.
export OPENCODE_ENABLE_TELEMETRY=1
export OPENCODE_OTLP_ENDPOINT=http://angel-2.taila8aaf1.ts.net:4317
export OPENCODE_OTLP_PROTOCOL=grpc
