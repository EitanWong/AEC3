#!/bin/bash

# Exit on error
set -e

echo "Building AEC3 C# wrapper..."

# Build the project
dotnet build -c Release
dotnet build -c Debug

# Check if the native library exists
LIB_PATH="../install/macos/lib/aec.dylib"

if [ ! -f "$LIB_PATH" ]; then
    echo "Warning: Native library not found at $LIB_PATH"
    echo "Make sure the AEC3 native library is built"
else
    echo "Found native library at $LIB_PATH"
fi

# Create output directories if they don't exist
mkdir -p bin/Release/net9.0
mkdir -p bin/Debug/net9.0

# Copy native library to output directories
if [ -f "$LIB_PATH" ]; then
    echo "Copying native library to Release output directory..."
    # cp "$LIB_PATH" bin/Release/net9.0/libaec3.dylib
    cp "$LIB_PATH" bin/Release/net9.0/aec3.dylib
    
    echo "Copying native library to Debug output directory..."
    # cp "$LIB_PATH" bin/Debug/net9.0/libaec3.dylib
    cp "$LIB_PATH" bin/Debug/net9.0/aec3.dylib
fi

# Run the example in test mode (using generated test data)
echo "Running example with generated test data..."
cd bin/Debug/net9.0
./AEC3Wrapper --test

echo "Done!" 