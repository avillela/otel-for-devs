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
