#!/bin/bash

# Source: https://opentelemetry.io/docs/languages/java/getting-started/

# -----------------------
# Running the app locally
# -----------------------

cd java-simple
gradle assemble
java -jar ./build/libs/java-simple.jar



# Requires a localhost Collector
export JAVA_TOOL_OPTIONS="-javaagent:opentelemetry-javaagent.jar" \
  OTEL_TRACES_EXPORTER=otlp, logging \
  OTEL_METRICS_EXPORTER=otlp, logging \
  OTEL_LOGS_EXPORTER=otlp, logging \
  OTEL_METRIC_EXPORT_INTERVAL=15000
export JAVA_TOOL_OPTIONS="-javaagent:opentelemetry-javaagent.jar" 

# Build the app
gradle assemble

# Start app
java -jar ./build/libs/otel-java-simple.jar

# Call the app once
curl localhost:8008/rolldice

# Call the app, incl. curl_log.txt
nohup ./random_curl.sh > curl_log.txt 2>&1



# Using Docker
# ---------------

# Build the image
docker build -t roll-dice-app .

# Run the image with OTel exporting to localhost Collector
docker run --network=host \
  -e OTEL_SERVICE_NAME=roll-dice-app \
  -e OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
  -e SERVER_PORT=8008 \
  roll-dice-app

docker images
docker ps
docker stop 7bef36ad6d18
