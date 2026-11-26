#!/bin/bash

### -----------------------
### Build the .NET apps locally
### (dotnet-rolldice-server-instrumented server + dotnet-rolldice-client)
### -----------------------

set -euo pipefail

# The solution in dotnet/ contains both projects; NuGet packages are
# referenced in each project's .csproj and restored by the build.
cd dotnet

echo "Building .NET solution..."
dotnet build
echo "Build complete!"

cd ..
