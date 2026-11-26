#!/bin/bash

### -----------------------
### Start the app
### -----------------------

# Load environment variables from .env file (default to .env if not provided)
ENV_FILE="${1:-.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file '$ENV_FILE' not found"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "$DOTNET_FOLDER" ]; then
  echo "Error: DOTNET_FOLDER not defined in $ENV_FILE"
  exit 1
fi

# Reference: https://opentelemetry.io/docs/languages/java/configuration/#properties-exporters

cd dotnet/$DOTNET_FOLDER

# export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
#   OTEL_TRACES_EXPORTER=console,otlp \
#   OTEL_METRICS_EXPORTER=console,otlp \
#   OTEL_LOGS_EXPORTER=console,otlp \
#   OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
#   OTEL_METRIC_EXPORT_INTERVAL=15000

dotnet run

