#!/bin/bash

# This script runs the OpenTelemetry Collector in Docker

COLLECTOR_VERSION="0.149.0"
CONFIG_PATH="./otel-collector/otelcol-config.yaml"

# Run the OpenTelemetry Collector
# -it: Interactive mode
# --rm: Automatically remove the container when it exits
# --name: Assign a name to the container
docker run -it --rm \
  -p 4317:4317 -p 4318:4318 \
  --name otelcol \
  -v "$(pwd)/otel-collector/otelcol-config.yaml:/etc/otelcol-config.yaml" \
  otel/opentelemetry-collector-contrib:$COLLECTOR_VERSION \
  --config /etc/otelcol-config.yaml