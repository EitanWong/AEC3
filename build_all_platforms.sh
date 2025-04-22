#!/bin/bash
set -e

# Root directory
ROOT_DIR=$(pwd)
BUILD_DIR="${ROOT_DIR}/build"
INSTALL_DIR="${ROOT_DIR}/install"

# Create directories
mkdir -p ${BUILD_DIR}
mkdir -p ${INSTALL_DIR}

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local cmake_options=$2
    local build_subdir="${BUILD_DIR}/${platform}"
    local install_subdir="${INSTALL_DIR}/${platform}"
    
    echo "===== Building for ${platform} ====="
    mkdir -p "${build_subdir}"
    mkdir -p "${install_subdir}"
    
    cd "${build_subdir}"
    cmake ${cmake_options} -DCMAKE_INSTALL_PREFIX="${install_subdir}" "${ROOT_DIR}"
    cmake --build . --config Release -j $(getconf _NPROCESSORS_ONLN)
    cmake --install . --config Release
    
    echo "===== Completed ${platform} build ====="
    echo ""
}

# Build for macOS (Universal binary - ARM64 and x86_64)
build_platform "macos" "-DBUILD_SHARED_LIBS=ON -DBUILD_MACOS=ON -DCMAKE_BUILD_TYPE=Release"

# Check if we're on macOS for iOS build
if [[ "$(uname)" == "Darwin" ]]; then
    # Build for iOS (requires Xcode)
    build_platform "ios" "-DBUILD_SHARED_LIBS=ON -DBUILD_IOS=ON -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_BUILD_TYPE=Release"
fi

# Build for Linux (if on Linux)
if [[ "$(uname)" == "Linux" ]]; then
    # Build for x86_64
    build_platform "linux-x86_64" "-DBUILD_SHARED_LIBS=ON -DBUILD_LINUX=ON -DCMAKE_BUILD_TYPE=Release"
    
    # Build for ARM (if cross-compiler is available)
    if command -v arm-linux-gnueabihf-gcc &> /dev/null; then
        build_platform "linux-arm" "-DBUILD_SHARED_LIBS=ON -DBUILD_LINUX=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++"
    fi
    
    # Build for ARM64 (if cross-compiler is available)
    if command -v aarch64-linux-gnu-gcc &> /dev/null; then
        build_platform "linux-arm64" "-DBUILD_SHARED_LIBS=ON -DBUILD_LINUX=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++"
    fi
fi

# Check if we have Android NDK for Android build
if [ -n "$ANDROID_NDK_ROOT" ]; then
    # Build for Android (armeabi-v7a)
    build_platform "android-armeabi-v7a" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=armeabi-v7a -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"
    
    # Build for Android (arm64-v8a)
    build_platform "android-arm64-v8a" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"
    
    # Build for Android (x86)
    build_platform "android-x86" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86 -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"
    
    # Build for Android (x86_64)
    build_platform "android-x86_64" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86_64 -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"
fi

echo "All builds completed successfully!"
echo "Libraries are in ${INSTALL_DIR}/<platform>/lib"
echo "Headers are in ${INSTALL_DIR}/<platform>/include" 