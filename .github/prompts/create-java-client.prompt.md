---
agent: 'agent'
model: GPT-4o
description: 'Create a Java client that calls the dice roller endpoint'
---

## Goal

Create a new Java client program for the `java-simple` example that calls the `/rolldice` endpoint. The client should be based on the bash script in `scripts/03-rolldice.sh` but implemented as a native Java application.

## Requirements

### Client Functionality
- Calls the endpoint `http://localhost:8080/rolldice` repeatedly
- Makes requests every 5 seconds (configurable interval)
- Logs all requests and responses using SLF4J
- Runs in an infinite loop until interrupted
- Mirrors the behavior of `scripts/03-rolldice.sh`

### Implementation Details

#### Java Client Class
- **File**: `java-simple/src/main/java/otel/RolldiceClient.java`
- **Package**: `otel`
- **Main class**: `RolldiceClient`
- **HTTP Client**: Use Java 11+ `java.net.http.HttpClient`
- **Logging**: Use SLF4J with timestamped log messages
- **Configuration**:
  - URL: `http://localhost:8080/rolldice`
  - Sleep interval: 5000ms between requests
  - Log level: INFO for requests/responses, ERROR for failures

#### Build Configuration
- Update `java-simple/build.gradle.kts`
- Add a custom Gradle task `clientJar` of type `Jar` to build a fat JAR
- Task should:
  - Set `archiveBaseName` to `"java-simple-client"`
  - Set `Main-Class` manifest attribute to `otel.RolldiceClient`
  - Include all dependencies from runtime classpath via `zipTree()`
  - **Important**: Set `duplicatesStrategy = DuplicatesStrategy.EXCLUDE` to handle duplicate files in dependencies
- Make both `tasks.assemble` and `tasks.build` depend on the `clientJar` task
- Ensure `./gradlew clean assemble` builds both the server JAR and client JAR

#### Startup Script
- **File**: `scripts/04-run-java-client.sh`
- **Type**: Bash shell script
- **Functionality**: 
  - Set up OpenTelemetry environment variables (same as server startup)
  - Enable OTLP exporters for traces, metrics, and logs
  - Build the client JAR if not already built
  - Run the client JAR with `java -jar build/libs/java-simple-client.jar`
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
   - Uses plain HTTP (no SSL handling)

2. **build.gradle.kts** - Updated build file
   - New `clientJar` task added to build a fat JAR
   - Includes `duplicatesStrategy = DuplicatesStrategy.EXCLUDE` to prevent build failures
   - Both `tasks.assemble` and `tasks.build` depend on `clientJar`
   - Project builds successfully with `./gradlew clean assemble`

3. **04-run-java-client.sh** - Startup script
   - Executable permissions set
   - Proper OpenTelemetry configuration
   - Builds client JAR if needed
   - Runs the JAR with `java -jar`
   - Clear console output

### Testing

Verify the implementation by:
1. Building the project: `./gradlew clean assemble` - produces both `java-simple.jar` and `java-simple-client.jar`
2. Confirming no compilation errors
3. Verifying both JAR files exist in `build/libs/`
4. Script is executable and can be invoked
5. Client connects to `http://localhost:8080/rolldice` (HTTP, not HTTPS)
