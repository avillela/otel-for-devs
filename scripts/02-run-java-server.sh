#!/bin/bash

### -----------------------
### Start the app
### -----------------------

# Reference: https://opentelemetry.io/docs/languages/java/configuration/#properties-exporters

export JAVA_TOOL_OPTIONS="-javaagent:opentelemetry-javaagent.jar" \
  OTEL_TRACES_EXPORTER=console,otlp \
  OTEL_METRICS_EXPORTER=console,otlp \
  OTEL_LOGS_EXPORTER=console,otlp \
  OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
  OTEL_METRIC_EXPORT_INTERVAL=15000

pwd
java -jar ./java-simple/build/libs/java-simple.jar
