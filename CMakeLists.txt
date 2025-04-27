cmake_minimum_required(VERSION 3.16)
project(AEC3 VERSION 1.0.0 LANGUAGES C CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add option to control platform builds
option(BUILD_SHARED_LIBS "Build as shared library" ON)
option(BUILD_ANDROID "Build for Android" OFF)
option(BUILD_IOS "Build for iOS" OFF)
option(BUILD_MACOS "Build for macOS" ON)
option(BUILD_WINDOWS "Build for Windows" OFF)
option(BUILD_LINUX "Build for Linux" OFF)
option(USE_SIMD "Enable SIMD optimizations" OFF)

# add_compile_options(-msse2)
# enable_language(ASM_NASM)
# set(CMAKE_ASM_NASM_FLAGS "-D__SSE2__ -DWEBRTC_ARCH_X86_FAMILY")
# add_definitions(-D__SSE2__ -DWEBRTC_ARCH_X86_FAMILY)

# Set position independent code for shared libraries
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Add SIMD stubs (for missing SSE2 implementations)
set(SIMD_STUBS_SOURCES
    sse2_stubs.cc
)

# API sources
set(API_SOURCES
    api/echo_canceller3_config.cc
    api/echo_canceller3_config_json.cc
    api/echo_canceller3_factory.cc
    api/aec3_api.cc
)

# System wrappers sources
set(SYSTEM_WRAPPERS_SOURCES
    base/system_wrappers/source/cpu_features.cc
    base/system_wrappers/source/field_trial.cc
    base/system_wrappers/source/metrics.cc
)

# Add conditional platform-specific sources
if(WIN32)
    list(APPEND SYSTEM_WRAPPERS_SOURCES base/system_wrappers/source/cpu_features_windows.c)
elseif(ANDROID)
    list(APPEND SYSTEM_WRAPPERS_SOURCES base/system_wrappers/source/cpu_features_android.c)
elseif(UNIX)
    list(APPEND SYSTEM_WRAPPERS_SOURCES base/system_wrappers/source/cpu_features_linux.c)
endif()

# RTC base sources
set(RTC_BASE_SOURCES
    base/rtc_base/time_utils.cc
    base/rtc_base/platform_thread_types.cc
    base/rtc_base/race_checker.cc
    base/rtc_base/string_encode.cc
    base/rtc_base/string_to_number.cc
    base/rtc_base/string_utils.cc
    base/rtc_base/critical_section.cc
    base/rtc_base/logging.cc
    base/rtc_base/checks.cc
    base/rtc_base/strings/string_builder.cc
    base/rtc_base/strings/json.cc
    base/rtc_base/memory/aligned_malloc.cc
    base/rtc_base/system/file_wrapper.cc
)

# JSON cpp sources
set(JSONCPP_SOURCES
    base/jsoncpp/src/lib_json/json_reader.cpp
    base/jsoncpp/src/lib_json/json_value.cpp
    base/jsoncpp/src/lib_json/json_writer.cpp
)

# Audio processing sources
set(AUDIO_PROCESSING_SOURCES
    audio_processing/audio_buffer.cc
    audio_processing/audio_frame.cc
    audio_processing/channel_buffer.cc
    audio_processing/channel_layout.cc
    audio_processing/high_pass_filter.cc
    audio_processing/sparse_fir_filter.cc
    audio_processing/splitting_filter.cc
    audio_processing/splitting_filter_c.c
    audio_processing/three_band_filter_bank.cc
    audio_processing/logging/apm_data_dumper.cc
    audio_processing/logging/wav_file.cc
    audio_processing/logging/wav_header.cc
    audio_processing/resampler/push_sinc_resampler.cc
    audio_processing/resampler/sinc_resampler.cc
    audio_processing/utility/cascaded_biquad_filter.cc
    audio_processing/utility/ooura_fft.cc
    audio_processing/utility/pffft_wrapper.cc
    audio_processing/utility/delay_estimator.cc
    audio_processing/utility/delay_estimator_wrapper.cc
    audio_processing/aec3/echo_remover.cc
    audio_processing/aec3/echo_remover_metrics.cc
    audio_processing/aec3/render_delay_buffer.cc
    audio_processing/aec3/render_delay_controller.cc
    audio_processing/aec3/render_delay_controller_metrics.cc
    audio_processing/aec3/render_buffer.cc
    audio_processing/aec3/render_signal_analyzer.cc
    audio_processing/aec3/residual_echo_estimator.cc
    audio_processing/aec3/subtractor.cc
    audio_processing/aec3/subtractor_output.cc
    audio_processing/aec3/suppression_filter.cc
    audio_processing/aec3/suppression_gain.cc
    audio_processing/aec3/echo_path_delay_estimator.cc
    audio_processing/aec3/echo_path_variability.cc
    audio_processing/aec3/downsampled_render_buffer.cc
    audio_processing/aec3/fft_buffer.cc
    audio_processing/aec3/spectrum_buffer.cc
    audio_processing/aec3/matched_filter.cc
    audio_processing/aec3/matched_filter_lag_aggregator.cc
    audio_processing/aec3/frame_blocker.cc
    audio_processing/aec3/filter_analyzer.cc
    audio_processing/aec3/erl_estimator.cc
    audio_processing/aec3/erle_estimator.cc
    audio_processing/aec3/fullband_erle_estimator.cc
    audio_processing/aec3/main_filter_update_gain.cc
    audio_processing/aec3/shadow_filter_update_gain.cc
    audio_processing/aec3/signal_dependent_erle_estimator.cc
    audio_processing/aec3/stationarity_estimator.cc
    audio_processing/aec3/subband_erle_estimator.cc
    audio_processing/aec3/subband_nearend_detector.cc
    audio_processing/aec3/reverb_decay_estimator.cc
    audio_processing/aec3/reverb_frequency_response.cc
    audio_processing/aec3/reverb_model.cc
    audio_processing/aec3/reverb_model_estimator.cc
    audio_processing/aec3/moving_average.cc
    audio_processing/aec3/aec3_common.cc
    audio_processing/aec3/aec3_fft.cc
    audio_processing/aec3/aec_state.cc
    audio_processing/aec3/adaptive_fir_filter.cc
    audio_processing/aec3/alignment_mixer.cc
    audio_processing/aec3/block_buffer.cc
    audio_processing/aec3/block_framer.cc
    audio_processing/aec3/block_processor.cc
    audio_processing/aec3/clockdrift_detector.cc
    audio_processing/aec3/comfort_noise_generator.cc
    audio_processing/aec3/decimator.cc
    audio_processing/aec3/dominant_nearend_detector.cc
    audio_processing/aec3/subtractor_output_analyzer.cc
    audio_processing/aec3/echo_audibility.cc
    audio_processing/aec3/block_processor_metrics.cc
    audio_processing/aec3/adaptive_fir_filter_erl.cc
    audio_processing/aec3/echo_canceller3.cc
    audio_processing/aec3/block_delay_buffer.cc
    audio_processing/aec3/api_call_jitter_metrics.cc
)

# Add Unity bridge source
# set(UNITY_BRIDGE_SOURCES
#     unity_bridge.cc
# )

# Combine all sources
set(ALL_SOURCES
    ${API_SOURCES}
    ${SYSTEM_WRAPPERS_SOURCES}
    ${RTC_BASE_SOURCES}
    ${JSONCPP_SOURCES}
    ${AUDIO_PROCESSING_SOURCES}
    ${SIMD_STUBS_SOURCES}
)

# Create the SSE2 stubs file
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/sse2_stubs.cc [[
#include <cstdint>

namespace webrtc {

class SincResampler {
public:
    void Convolve_SSE(const float* input_ptr, const float* k1, const float* k2, double initial_position);
};

void SincResampler::Convolve_SSE(const float* input_ptr, const float* k1, const float* k2, double initial_position) {
    // This should never be called because we disable SSE at compile time
}

void cft1st_128_SSE2(float* a) {
    // This should never be called because we disable SSE at compile time
}

void cftmdl_128_SSE2(float* a) {
    // This should never be called because we disable SSE at compile time
}

void rftbsub_128_SSE2(float* a) {
    // This should never be called because we disable SSE at compile time
}

void rftfsub_128_SSE2(float* a) {
    // This should never be called because we disable SSE at compile time
}

}  // namespace webrtc
]])

# Create a single library with simplified name
add_library(libaec3 ${ALL_SOURCES})

# Set library output name - removing 'lib' prefix on non-Windows platforms
set_target_properties(libaec3 PROPERTIES 
    OUTPUT_NAME "aec3"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    PREFIX ""
)

# Set up include directories
target_include_directories(libaec3 
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/api>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/base
        ${CMAKE_CURRENT_SOURCE_DIR}/base/abseil
        ${CMAKE_CURRENT_SOURCE_DIR}/base/jsoncpp/include
        ${CMAKE_CURRENT_SOURCE_DIR}/audio_processing
        ${CMAKE_CURRENT_SOURCE_DIR}/audio_processing/include
        ${CMAKE_CURRENT_BINARY_DIR}
)

# Add global define for APM debug dump
target_compile_definitions(libaec3 PRIVATE WEBRTC_APM_DEBUG_DUMP=0)

# Add include directories for the SIMD stubs
if(NOT USE_SIMD)
    # Disable architecture-specific SIMD optimizations
    target_compile_definitions(libaec3 PRIVATE 
        WEBRTC_ARCH_ARM_NEON=0 
        WEBRTC_ARCH_X86_SSE2=0
        WEBRTC_DISABLE_SSE2=1
    )
endif()

# Set up platform-specific compile definitions
if(WIN32)
    target_compile_definitions(libaec3 PRIVATE WEBRTC_WIN NOMINMAX WIN32_LEAN_AND_MEAN)
elseif(APPLE)
    target_compile_definitions(libaec3 PRIVATE WEBRTC_POSIX WEBRTC_MAC)
    # Link CoreFoundation on macOS/iOS
    find_library(CORE_FOUNDATION_FRAMEWORK CoreFoundation)
    if(CORE_FOUNDATION_FRAMEWORK)
        target_link_libraries(libaec3 PRIVATE ${CORE_FOUNDATION_FRAMEWORK})
    endif()
elseif(ANDROID)
    target_compile_definitions(libaec3 PRIVATE WEBRTC_POSIX WEBRTC_ANDROID __STDC_FORMAT_MACROS)
elseif(IOS)
    target_compile_definitions(libaec3 PRIVATE WEBRTC_POSIX WEBRTC_IOS WEBRTC_MAC)
    # Link CoreFoundation on macOS/iOS
    find_library(CORE_FOUNDATION_FRAMEWORK CoreFoundation)
    if(CORE_FOUNDATION_FRAMEWORK)
        target_link_libraries(libaec3 PRIVATE ${CORE_FOUNDATION_FRAMEWORK})
    endif()
elseif(UNIX)
    target_compile_definitions(libaec3 PRIVATE WEBRTC_POSIX WEBRTC_LINUX)
endif()

# Special flags for C files
set_source_files_properties(
    audio_processing/splitting_filter_c.c
    PROPERTIES COMPILE_FLAGS "-include stddef.h"
)

# Add include for stddef.h to fix size_t issue in C files
if(WIN32)
    target_compile_options(libaec3 PRIVATE /EHsc /MP)
else()
    target_compile_options(libaec3 PRIVATE -Wno-deprecated-builtins -Wno-macro-redefined)
endif()

# Platform-specific configurations
if(BUILD_MACOS)
    # Properly set architecture based on CMake arguments
    if(APPLE AND BUILD_MACOS)
        # Don't enable multi-architecture build via OSX_ARCHITECTURES here
        # This will be handled by the build script for each separate architecture
    endif()
endif()

if(BUILD_ANDROID)
    # Android-specific setup
    set(CMAKE_ANDROID_STL_TYPE c++_shared)
    set(CMAKE_ANDROID_API 21)
    # You would typically set these via the command line with:
    # -DANDROID_ABI="armeabi-v7a;arm64-v8a;x86;x86_64"
endif()

if(BUILD_IOS)
    # iOS-specific setup
    set_target_properties(libaec3 PROPERTIES
        XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "11.0"
        XCODE_ATTRIBUTE_ENABLE_BITCODE "YES"
        XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO"
    )
    # Universal iOS binary (simulator and device)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
endif()

# Export and install targets
include(CMakePackageConfigHelpers)
set(CONFIG_INSTALL_DIR lib/cmake/aec)

# Generate export helpers
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/AEC3Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/aecConfig.cmake
    INSTALL_DESTINATION ${CONFIG_INSTALL_DIR}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/aecConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Install the targets and export files
install(TARGETS libaec3
    EXPORT aecTargets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT aecTargets
    FILE aecTargets.cmake
    NAMESPACE aec::
    DESTINATION ${CONFIG_INSTALL_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/aecConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/aecConfigVersion.cmake
    DESTINATION ${CONFIG_INSTALL_DIR}
)

# Install headers
install(FILES api/aec3_api.h
    DESTINATION include
) 