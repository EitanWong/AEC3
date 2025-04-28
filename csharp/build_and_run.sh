#!/bin/bash

# Exit on error
set -e

echo "Building AEC3 C# wrapper..."

# Build the project
dotnet build -c Release
dotnet build -c Debug

# Check if the native library exists
LIB_PATH="../install/macos/lib/aec3.dylib"

if [ ! -f "$LIB_PATH" ]; then
    echo "Warning: Native library not found at $LIB_PATH"
    
    # Try alternate locations
    ALT_PATHS=(
        "../install/macos-arm64/lib/aec3.dylib"
        "../install/macos-x86_64/lib/aec3.dylib"
    )
    
    for ALT_PATH in "${ALT_PATHS[@]}"; do
        if [ -f "$ALT_PATH" ]; then
            echo "Found library at alternate location: $ALT_PATH"
            LIB_PATH="$ALT_PATH"
            break
        fi
    done
    
    if [ ! -f "$LIB_PATH" ]; then
        echo "Could not find AEC3 library. Make sure the AEC3 native library is built."
        exit 1
    fi
fi

echo "Using native library: $LIB_PATH"

# Create output directories if they don't exist
mkdir -p bin/Release/net9.0
mkdir -p bin/Debug/net9.0

# Copy native library to output directories
if [ -f "$LIB_PATH" ]; then
    echo "Copying native library to Release output directory..."
    cp "$LIB_PATH" bin/Release/net9.0/aec3.dylib
    
    echo "Copying native library to Debug output directory..."
    cp "$LIB_PATH" bin/Debug/net9.0/aec3.dylib
fi

# Run the example in test mode (using generated test data)
echo "Running example with generated test data (no delay)..."
cd bin/Debug/net9.0
./AEC3Wrapper --test

echo "Running example with generated test data (40 sample delay)..."
./AEC3Wrapper --test --delay 40

echo "Done!" 