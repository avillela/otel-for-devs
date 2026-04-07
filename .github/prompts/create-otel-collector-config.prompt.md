---
agent: 'agent'
model: GPT-4o
description: 'Create a base Collector config YAML'
---

## Goal

Create a bare-bones OTel Collector config YAML file.

## Configuration Details

### Exporters
- **debug**: Verbose debug exporter for local testing and development
- **otlphttp**: OTLP HTTP exporter with batching via sending_queue

### Receivers
- **OTLP**: Supports both GRPC and HTTP protocols
  - GRPC endpoint: `0.0.0.0:4317`
  - HTTP endpoint: `0.0.0.0:4318`

### Connectors
- **spanmetrics**: Generates metrics from trace spans

### Pipelines
The collector runs three data pipelines:

1. **Traces Pipeline**
   - Receives: OTLP
   - Connectors: spanmetrics
   - Exporters: debug, otlphttp

2. **Metrics Pipeline**
   - Receives: OTLP, spanmetrics
   - Exporters: debug, otlphttp

3. **Logs Pipeline**
   - Receives: OTLP
   - Exporters: debug, otlphttp

## Key Features
- **Batching**: The otlphttp exporter includes a sending_queue for efficient batching
- **Verbosity**: Debug exporter is set to detailed for comprehensive logging
- **Dual Protocols**: OTLP receiver accepts both gRPC and HTTP connections
- **Span Metrics**: spanmetrics connector automatically converts spans into metrics

## Output

The configuration is stored as a YAML file in `otel-collector/otelcol-config.yaml`
