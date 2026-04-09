#!/bin/bash

### -----------------------
### Start the Rolldice Client
### -----------------------

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

# cd java-simple

# # Build the client jar if not already built
# if [ ! -f "build/libs/java-simple-client.jar" ]; then
#   echo "Building client jar..."
#   ./gradlew clientJar
# fi

java -jar ./java-simple/build/libs/java-simple-client.jar
