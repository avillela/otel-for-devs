#!/bin/bash

### -----------------------
### Build the .NET app locally
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

cd "dotnet/$DOTNET_FOLDER"

# Build script for dotnet-simple project

set -e

echo "Add Nuget packages"
# dotnet add package OpenTelemetry.Extensions.Hosting
# dotnet add package OpenTelemetry.Instrumentation.AspNetCore
# dotnet add package OpenTelemetry.Exporter.Console
dotnet add package OpenTelemetry.Extensions.Hosting
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.Http


echo "Building .net project..."
dotnet build
echo "Build complete!"

cd ..