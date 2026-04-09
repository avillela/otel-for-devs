#!/bin/bash

### -----------------------
### Build the app locally
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

cd "$JAVA_FOLDER"

# Build script for java-simple project
# Sets up Gradle 8.5 wrapper and assembles the project

set -e

echo "Creating Gradle 8.5 wrapper..."
gradle wrapper --gradle-version 8.5

echo "Building project with Gradle assemble..."
./gradlew clean assemble

echo "Build complete!"

cd ..