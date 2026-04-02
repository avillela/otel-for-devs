---
agent: 'agent'
model: GPT-4o
description: 'Create a base Collector config YAML'
---

## Goal

Create a shell script that runs the OTel Collector in Docker.

## Configuration Details

Details:
* Use [OTel Collector contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib)
* Collector version: `0.149.0`
* Collector config YAML path: ./otel-collector/otelcol-config.yaml
* Docker run guidance: 
   * Do NOT run in background. Use `docker run -it --rm`
   * Container name: `otelcol`
   * Add port-forwarding for 4317 and 4319


## Output

* Save script to `scripts/02-run-otel-collector.sh`
* Make the script executable
