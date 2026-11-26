#!/bin/bash

### -----------------------
### Start the Rolldice Client
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

# export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
#   OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
#   OTEL_METRIC_EXPORT_INTERVAL=15000

echo "Starting Rolldice Client..."
echo "Calling endpoint: http://localhost:8080/rolldice"
echo ""

# The client is its own project and works against either server folder
cd dotnet/dotnet-rolldice-client

dotnet run
