#!/bin/bash

### -----------------------
### Build the .NET app locally
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

if [ -z "$DOTNET_FOLDER" ]; then
  echo "Error: DOTNET_FOLDER not defined in $ENV_FILE"
  exit 1
fi

cd "dotnet/$DOTNET_FOLDER"

# Build script for dotnet-simple project

set -e

echo "Building .net project..."
dotnet build
echo "Build complete!"

cd ..