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

if [ -z "$JAVA_FOLDER" ]; then
  echo "Error: JAVA_FOLDER not defined in $ENV_FILE"
  exit 1
fi

# Reference: https://opentelemetry.io/docs/languages/java/configuration/#properties-exporters

export JAVA_TOOL_OPTIONS="-javaagent:opentelemetry-javaagent.jar" \
  OTEL_TRACES_EXPORTER=console,otlp \
  OTEL_METRICS_EXPORTER=console,otlp \
  OTEL_LOGS_EXPORTER=console,otlp \
  OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
  OTEL_METRIC_EXPORT_INTERVAL=15000

echo "Starting Rolldice Client..."
echo "Calling endpoint: https://localhost:8080/rolldice"
echo ""

# cd $JAVA_FOLDER

# # Build the client jar if not already built
# if [ ! -f "build/libs/${JAVA_FOLDER}-client.jar" ]; then
#   echo "Building client jar..."
#   ./gradlew clientJar
# fi

java -jar "./$JAVA_FOLDER/build/libs/${JAVA_FOLDER}-client.jar"
