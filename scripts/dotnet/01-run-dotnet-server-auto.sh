#!/bin/bash

### -----------------------
### Run dotnet-rolldice-server with the OpenTelemetry .NET
### Automatic Instrumentation (zero code changes)
### -----------------------

# Reference: https://opentelemetry.io/docs/zero-code/dotnet/

set -e

SERVER_FOLDER="dotnet-rolldice-server"
OTEL_DOTNET_AUTO_HOME="${OTEL_DOTNET_AUTO_HOME:-$HOME/.otel-dotnet-auto}"
export OTEL_DOTNET_AUTO_HOME

# Install the auto-instrumentation agent if it isn't there yet
if [ ! -f "$OTEL_DOTNET_AUTO_HOME/instrument.sh" ]; then
  echo "Installing OpenTelemetry .NET auto-instrumentation to $OTEL_DOTNET_AUTO_HOME..."
  INSTALLER="$(mktemp)"
  curl -sSfL -o "$INSTALLER" \
    https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/latest/download/otel-dotnet-auto-install.sh
  # 'gh' CLI isn't available in this environment, so skip release verification
  SKIP_RELEASE_VERIFICATION=true bash "$INSTALLER"
  rm -f "$INSTALLER"
fi

cd "dotnet/$SERVER_FOLDER"

# Build BEFORE loading the profiler, so the build itself isn't instrumented
echo "Building $SERVER_FOLDER..."
dotnet build

# Load the profiler environment variables (CORECLR_*, DOTNET_STARTUP_HOOKS, ...)
# shellcheck disable=SC1091
source "$OTEL_DOTNET_AUTO_HOME/instrument.sh"

export OTEL_SERVICE_NAME=roll-dice-server \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
  OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
  OTEL_TRACES_EXPORTER=console,otlp \
  OTEL_METRICS_EXPORTER=console,otlp \
  OTEL_LOGS_EXPORTER=console,otlp \
  OTEL_METRIC_EXPORT_INTERVAL=15000

# Run the built DLL directly (rather than `dotnet run`) so the profiler
# attaches to the app and not to the dotnet CLI. launchSettings.json isn't
# used in this mode, so set the URL explicitly.
export ASPNETCORE_URLS=http://localhost:8080
export ASPNETCORE_ENVIRONMENT=Development

dotnet "bin/Debug/net10.0/$SERVER_FOLDER.dll"
