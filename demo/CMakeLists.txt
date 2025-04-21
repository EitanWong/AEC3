cmake_minimum_required(VERSION 3.10)
project(demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add WebRTC source files
set(API_SOURCES
    ${CMAKE_SOURCE_DIR}/../api/echo_canceller3_config.cc
    ${CMAKE_SOURCE_DIR}/../api/echo_canceller3_config_json.cc
    ${CMAKE_SOURCE_DIR}/../api/echo_canceller3_factory.cc
)

# Add system_wrappers sources
set(SYSTEM_WRAPPERS_SOURCES
    ${CMAKE_SOURCE_DIR}/../base/system_wrappers/source/cpu_features.cc
    ${CMAKE_SOURCE_DIR}/../base/system_wrappers/source/cpu_features_android.c
    ${CMAKE_SOURCE_DIR}/../base/system_wrappers/source/cpu_features_linux.c
    ${CMAKE_SOURCE_DIR}/../base/system_wrappers/source/field_trial.cc
    ${CMAKE_SOURCE_DIR}/../base/system_wrappers/source/metrics.cc
)

# Add rtc_base sources
set(RTC_BASE_SOURCES
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/time_utils.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/platform_thread_types.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/race_checker.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/string_encode.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/string_to_number.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/string_utils.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/critical_section.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/logging.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/checks.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/strings/string_builder.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/strings/json.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/memory/aligned_malloc.cc
    ${CMAKE_SOURCE_DIR}/../base/rtc_base/system/file_wrapper.cc
)

# Add jsoncpp sources
set(JSONCPP_SOURCES
    ${CMAKE_SOURCE_DIR}/../base/jsoncpp/src/lib_json/json_reader.cpp
    ${CMAKE_SOURCE_DIR}/../base/jsoncpp/src/lib_json/json_value.cpp
    ${CMAKE_SOURCE_DIR}/../base/jsoncpp/src/lib_json/json_writer.cpp
)

set(AUDIO_PROCESSING_SOURCES
    ${CMAKE_SOURCE_DIR}/../audio_processing/audio_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/audio_frame.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/channel_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/channel_layout.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/high_pass_filter.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/sparse_fir_filter.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/splitting_filter.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/splitting_filter_c.c
    ${CMAKE_SOURCE_DIR}/../audio_processing/three_band_filter_bank.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/logging/apm_data_dumper.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/logging/wav_file.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/logging/wav_header.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/resampler/push_sinc_resampler.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/resampler/sinc_resampler.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/utility/cascaded_biquad_filter.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/utility/ooura_fft.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/utility/pffft_wrapper.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/utility/delay_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/utility/delay_estimator_wrapper.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/echo_remover.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/echo_remover_metrics.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/render_delay_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/render_delay_controller.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/render_delay_controller_metrics.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/render_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/render_signal_analyzer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/residual_echo_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/subtractor.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/subtractor_output.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/suppression_filter.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/suppression_gain.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/echo_path_delay_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/echo_path_variability.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/downsampled_render_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/fft_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/spectrum_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/matched_filter.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/matched_filter_lag_aggregator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/frame_blocker.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/filter_analyzer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/erl_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/erle_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/fullband_erle_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/main_filter_update_gain.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/shadow_filter_update_gain.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/signal_dependent_erle_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/stationarity_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/subband_erle_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/subband_nearend_detector.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/reverb_decay_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/reverb_frequency_response.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/reverb_model.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/reverb_model_estimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/moving_average.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/aec3_common.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/aec3_fft.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/aec_state.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/adaptive_fir_filter.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/alignment_mixer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/block_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/block_framer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/block_processor.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/clockdrift_detector.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/comfort_noise_generator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/decimator.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/dominant_nearend_detector.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/subtractor_output_analyzer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/echo_audibility.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/block_processor_metrics.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/adaptive_fir_filter_erl.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/echo_canceller3.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/block_delay_buffer.cc
    ${CMAKE_SOURCE_DIR}/../audio_processing/aec3/api_call_jitter_metrics.cc
)

# Add demo source files
set(SOURCES
    demo.cc
    wavreader.c
    wavwriter.c
    ${API_SOURCES}
    ${SYSTEM_WRAPPERS_SOURCES}
    ${RTC_BASE_SOURCES}
    ${JSONCPP_SOURCES}
    ${AUDIO_PROCESSING_SOURCES}
)

# Add header files
set(HEADERS
    wavreader.h
    wavwriter.h
)

# Create executable
add_executable(demo ${SOURCES} ${HEADERS})

# Include directories
target_include_directories(demo PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/..
    ${CMAKE_SOURCE_DIR}/../base
    ${CMAKE_SOURCE_DIR}/../base/abseil
    ${CMAKE_SOURCE_DIR}/../base/jsoncpp/include
    ${CMAKE_SOURCE_DIR}/../audio_processing
    ${CMAKE_SOURCE_DIR}/../api
)

# Define required macros
target_compile_definitions(demo PRIVATE
    WEBRTC_POSIX
    WEBRTC_MAC
)

# Set compiler flags for macOS ARM
if(APPLE AND CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -arch arm64")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch arm64")
endif()

# Add include for stddef.h to fix size_t issue in C files
set_source_files_properties(
    ${CMAKE_SOURCE_DIR}/../audio_processing/splitting_filter_c.c
    PROPERTIES COMPILE_FLAGS "-include stddef.h"
)

target_compile_options(demo PRIVATE
    -Wno-deprecated-builtins
) 