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

echo "Starting Rolldice Client..."
echo "Calling endpoint: http://localhost:8080/rolldice"
echo ""

# The client is its own project and works against either server folder
cd dotnet/dotnet-rolldice-client

# Export metrics every 15s instead of the 60s default, so they show up quickly in the demo
export OTEL_METRIC_EXPORT_INTERVAL=15000

dotnet run
