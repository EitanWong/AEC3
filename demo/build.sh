#!/bin/bash

# Exit on error
set -e

# Create build directory if it doesn't exist
mkdir -p build

# Navigate to build directory
cd build

# Configure with CMake
cmake ..

# Build
make -j$(sysctl -n hw.ncpu)

echo "Build completed successfully!"
echo "The demo executable is located at: $(pwd)/demo"
