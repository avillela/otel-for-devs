---
agent: 'agent'
model: GPT-4o
description: 'Create a Java client that calls the dice roller endpoint'
---

## Goal

Create a new Java client program for the `java-simple` example that calls the `/rolldice` endpoint. The client should be based on the bash script in `scripts/03-rolldice.sh` but implemented as a native Java application.

## Requirements

### Client Functionality
- Calls the endpoint `https://localhost:8080/rolldice` repeatedly
- Makes requests every 5 seconds (configurable interval)
- Logs all requests and responses using SLF4J
- Handles self-signed certificates (development environment)
- Runs in an infinite loop until interrupted
- Mirrors the behavior of `scripts/03-rolldice.sh`

### Implementation Details

#### Java Client Class
- **File**: `java-simple/src/main/java/otel/RolldiceClient.java`
- **Package**: `otel`
- **Main class**: `RolldiceClient`
- **HTTP Client**: Use Java 11+ `java.net.http.HttpClient`
- **SSL Handling**: Implement custom SSL context to accept self-signed certificates
- **Logging**: Use SLF4J with timestamped log messages
- **Configuration**:
  - URL: `https://localhost:8080/rolldice`
  - Sleep interval: 5000ms between requests
  - Log level: INFO for requests/responses, ERROR for failures

#### Build Configuration
- Update `java-simple/build.gradle.kts`
- Add a Gradle task `runClient` of type `JavaExec`
- Task should:
  - Specify `otel.RolldiceClient` as mainClass
  - Use the main sourceset runtime classpath
  - Group: "application"
  - Description: "Run the Rolldice Client"

#### Startup Script
- **File**: `scripts/04-run-java-client.sh`
- **Type**: Bash shell script
- **Functionality**: 
  - Set up OpenTelemetry environment variables (same as server startup)
  - Enable OTLP exporters for traces, metrics, and logs
  - Run `./gradlew runClient` from the java-simple directory
- **Export Variables**:
  - `JAVA_TOOL_OPTIONS` with javaagent
  - `OTEL_TRACES_EXPORTER=console,otlp`
  - `OTEL_METRICS_EXPORTER=console,otlp`
  - `OTEL_LOGS_EXPORTER=console,otlp`
  - `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf`
  - `OTEL_METRIC_EXPORT_INTERVAL=15000`
- Make the script executable

### Deliverables

1. **RolldiceClient.java** - The main client class
   - Compiles without errors
   - Includes proper documentation/comments
   - Handles exceptions gracefully

2. **build.gradle.kts** - Updated build file
   - New `runClient` task added
   - Project continues to build successfully

3. **04-run-java-client.sh** - Startup script
   - Executable permissions set
   - Proper OpenTelemetry configuration
   - Clear console output

### Testing

Verify the implementation by:
1. Building the project: `./gradlew build`
2. Confirming no compilation errors
3. Script is executable and can be invoked
