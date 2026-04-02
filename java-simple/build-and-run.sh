#!/bin/bash

### -----------------------
### Build the app locally
### -----------------------

# Build script for java-simple project
# Sets up Gradle 8.5 wrapper and assembles the project

set -e

echo "Creating Gradle 8.5 wrapper..."
gradle wrapper --gradle-version 8.5

echo "Building project with Gradle assemble..."
./gradlew clean assemble

echo "Build complete!"

### -----------------------
### Start the app
### -----------------------

export JAVA_TOOL_OPTIONS="-javaagent:opentelemetry-javaagent.jar" \
  OTEL_TRACES_EXPORTER=logging \
  OTEL_METRICS_EXPORTER=logging \
  OTEL_LOGS_EXPORTER=logging \
  OTEL_METRIC_EXPORT_INTERVAL=15000

java -jar ./build/libs/java-simple.jar

