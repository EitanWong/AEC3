#!/bin/bash
set -e

# Print colorful output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Root directory
ROOT_DIR=$(pwd)
BUILD_DIR="${ROOT_DIR}/build"
INSTALL_DIR="${ROOT_DIR}/install"

# Create directories
mkdir -p ${BUILD_DIR}
mkdir -p ${INSTALL_DIR}

# Print info about the build
echo -e "${YELLOW}Building AEC acoustic echo cancellation library${NC}"
echo -e "${YELLOW}Root directory: ${ROOT_DIR}${NC}"

# clean install directory
echo -e "${YELLOW}Cleaning install directory${NC}"
rm -rf ${INSTALL_DIR}
echo -e "${GREEN}Install directory cleaned${NC}"

# clean build directory
echo -e "${YELLOW}Cleaning build directory${NC}"
rm -rf ${BUILD_DIR}
echo -e "${GREEN}Build directory cleaned${NC}"

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local cmake_options=$2
    local build_subdir="${BUILD_DIR}/${platform}"
    local install_subdir="${INSTALL_DIR}/${platform}"
    
    echo -e "${GREEN}===== Building for ${platform} =====${NC}"
    mkdir -p "${build_subdir}"
    mkdir -p "${install_subdir}"
    
    cd "${build_subdir}"
    
    # Clear existing build files to ensure clean build
    rm -rf ${build_subdir}/CMakeCache.txt
    
    echo -e "${YELLOW}Running cmake with options: ${cmake_options}${NC}"
    if ! cmake ${cmake_options} -DCMAKE_INSTALL_PREFIX="${install_subdir}" "${ROOT_DIR}"; then
        echo -e "${RED}CMake configuration failed for ${platform}${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Building project...${NC}"
    if ! cmake --build . --config Release -j $(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4); then
        echo -e "${RED}Build failed for ${platform}${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Installing...${NC}"
    if ! cmake --install . --config Release; then
        echo -e "${RED}Installation failed for ${platform}${NC}"
        return 1
    fi
    
    echo -e "${GREEN}===== Completed ${platform} build =====${NC}"
    echo ""
    
    # Return to root directory
    cd "${ROOT_DIR}"
    return 0
}

# Store failed platforms
FAILED_PLATFORMS=()

# Detect host system
HOST_SYSTEM=$(uname)
echo -e "${YELLOW}Host system detected as: ${HOST_SYSTEM}${NC}"

# Build for macOS (ARM64 and x86_64 separately)
if [[ "${HOST_SYSTEM}" == "Darwin" ]]; then
    echo -e "${YELLOW}Building for macOS ARM64${NC}"
    if ! build_platform "macos-arm64" "-DBUILD_SHARED_LIBS=ON -DBUILD_MACOS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64"; then
        FAILED_PLATFORMS+=("macOS-ARM64")
    fi
    
    echo -e "${YELLOW}Building for macOS x86_64${NC}"
    if ! build_platform "macos-x86_64" "-DBUILD_SHARED_LIBS=ON -DBUILD_MACOS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64"; then
        FAILED_PLATFORMS+=("macOS-x86_64")
    fi

    # Create a universal binary if both builds succeed
    if [[ ! " ${FAILED_PLATFORMS[*]} " =~ "macOS-ARM64" ]] && [[ ! " ${FAILED_PLATFORMS[*]} " =~ "macOS-x86_64" ]]; then
        echo -e "${YELLOW}Creating macOS universal binary${NC}"
        mkdir -p "${INSTALL_DIR}/macos/lib"
        mkdir -p "${INSTALL_DIR}/macos/include"
        
        # Create universal binary with the new library name
        lipo -create "${INSTALL_DIR}/macos-arm64/lib/aec3.dylib" "${INSTALL_DIR}/macos-x86_64/lib/aec3.dylib" -output "${INSTALL_DIR}/macos/lib/aec3.dylib"
        
        # Copy the cmake files for the new library
        mkdir -p "${INSTALL_DIR}/macos/lib/cmake/aec"
        cp -R "${INSTALL_DIR}/macos-arm64/lib/cmake/aec/"* "${INSTALL_DIR}/macos/lib/cmake/aec/"
        
        # Copy headers
        cp -R "${INSTALL_DIR}/macos-arm64/include/"* "${INSTALL_DIR}/macos/include/"
        
        echo -e "${GREEN}Universal binary created at: ${INSTALL_DIR}/macos/lib/aec3.dylib${NC}"
    fi

    # Build for iOS (requires Xcode)
    if command -v xcodebuild &> /dev/null; then
        echo -e "${YELLOW}Building for iOS${NC}"
        if ! build_platform "ios" "-DBUILD_SHARED_LIBS=ON -DBUILD_IOS=ON -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_BUILD_TYPE=Release"; then
            FAILED_PLATFORMS+=("iOS")
        fi
    else
        echo -e "${YELLOW}Skipping iOS build: Xcode not found${NC}"
    fi
fi

# Build for Linux (if on Linux)
if [[ "${HOST_SYSTEM}" == "Linux" ]]; then
    echo -e "${YELLOW}Building for Linux x86_64${NC}"
    if ! build_platform "linux-x86_64" "-DBUILD_SHARED_LIBS=ON -DBUILD_LINUX=ON -DCMAKE_BUILD_TYPE=Release"; then
        FAILED_PLATFORMS+=("Linux-x86_64")
    fi
    
    # Build for ARM (if cross-compiler is available)
    if command -v arm-linux-gnueabihf-gcc &> /dev/null; then
        echo -e "${YELLOW}Building for Linux ARM${NC}"
        if ! build_platform "linux-arm" "-DBUILD_SHARED_LIBS=ON -DBUILD_LINUX=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++"; then
            FAILED_PLATFORMS+=("Linux-ARM")
        fi
    else
        echo -e "${YELLOW}Skipping Linux ARM build: cross-compiler not found${NC}"
    fi
    
    # Build for ARM64 (if cross-compiler is available)
    if command -v aarch64-linux-gnu-gcc &> /dev/null; then
        echo -e "${YELLOW}Building for Linux ARM64${NC}"
        if ! build_platform "linux-arm64" "-DBUILD_SHARED_LIBS=ON -DBUILD_LINUX=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++"; then
            FAILED_PLATFORMS+=("Linux-ARM64")
        fi
    else
        echo -e "${YELLOW}Skipping Linux ARM64 build: cross-compiler not found${NC}"
    fi
fi

# Build for Windows (if on Windows)
if [[ "${HOST_SYSTEM}" == "MINGW"* ]] || [[ "${HOST_SYSTEM}" == "MSYS"* ]] || [[ "${HOST_SYSTEM}" == "CYGWIN"* ]]; then
    echo -e "${YELLOW}Building for Windows${NC}"
    if ! build_platform "windows" "-DBUILD_SHARED_LIBS=ON -DBUILD_WINDOWS=ON -DCMAKE_BUILD_TYPE=Release"; then
        FAILED_PLATFORMS+=("Windows")
    fi
fi

# Check if we have Android NDK for Android build
if [ -n "$ANDROID_NDK_ROOT" ]; then
    echo -e "${YELLOW}Android NDK found at: ${ANDROID_NDK_ROOT}${NC}"
    
    # Build for Android (armeabi-v7a)
    echo -e "${YELLOW}Building for Android ARMv7${NC}"
    if ! build_platform "android-armeabi-v7a" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=armeabi-v7a -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"; then
        FAILED_PLATFORMS+=("Android-ARMv7")
    fi
    
    # Build for Android (arm64-v8a)
    echo -e "${YELLOW}Building for Android ARM64${NC}"
    if ! build_platform "android-arm64-v8a" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"; then
        FAILED_PLATFORMS+=("Android-ARM64")
    fi
    
    # Build for Android (x86)
    echo -e "${YELLOW}Building for Android x86${NC}"
    if ! build_platform "android-x86" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86 -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"; then
        FAILED_PLATFORMS+=("Android-x86")
    fi
    
    # Build for Android (x86_64)
    echo -e "${YELLOW}Building for Android x86_64${NC}"
    if ! build_platform "android-x86_64" "-DBUILD_SHARED_LIBS=ON -DBUILD_ANDROID=ON -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86_64 -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release"; then
        FAILED_PLATFORMS+=("Android-x86_64")
    fi
else
    echo -e "${YELLOW}Skipping Android builds: Android NDK not found (set ANDROID_NDK_ROOT environment variable)${NC}"
fi

# Print summary
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}            Build Summary             ${NC}"
echo -e "${GREEN}=======================================${NC}"

if [ ${#FAILED_PLATFORMS[@]} -eq 0 ]; then
    echo -e "${GREEN}All builds completed successfully!${NC}"
else
    echo -e "${RED}Some builds failed: ${FAILED_PLATFORMS[*]}${NC}"
fi

echo -e "${YELLOW}Libraries are in ${INSTALL_DIR}/<platform>/lib${NC}"
echo -e "${YELLOW}Headers are in ${INSTALL_DIR}/<platform>/include${NC}" 