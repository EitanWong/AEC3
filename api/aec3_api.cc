#include "aec3_api.h"
#include "echo_canceller3_factory.h"
#include "echo_canceller3_config.h"
#include "../audio_processing/include/audio_processing.h"
#include "../audio_processing/audio_buffer.h"
#include "../audio_processing/high_pass_filter.h"

using namespace webrtc;

struct aec3_handle {
    std::unique_ptr<EchoControl> echo_controller;
    std::unique_ptr<HighPassFilter> hp_filter;
    std::unique_ptr<AudioBuffer> ref_audio;
    std::unique_ptr<AudioBuffer> aec_audio;
    std::unique_ptr<AudioBuffer> aec_linear_audio;
    AudioFrame ref_frame;
    AudioFrame aec_frame;
    int sample_rate;
    int num_channels;
};

aec3_handle_t* aec3_create(const aec3_config_t* config) {
    if (!config) return nullptr;

    auto handle = new aec3_handle_t;
    handle->sample_rate = config->sample_rate;
    handle->num_channels = config->num_channels;

    EchoCanceller3Config aec_config;
    aec_config.filter.export_linear_aec_output = config->export_linear;
    EchoCanceller3Factory aec_factory(aec_config);
    
    handle->echo_controller = aec_factory.Create(
        config->sample_rate, config->num_channels, config->num_channels);
    handle->hp_filter = std::make_unique<HighPassFilter>(
        config->sample_rate, config->num_channels);

    StreamConfig stream_config(config->sample_rate, config->num_channels, false);
    handle->ref_audio = std::make_unique<AudioBuffer>(
        stream_config.sample_rate_hz(), stream_config.num_channels(),
        stream_config.sample_rate_hz(), stream_config.num_channels(),
        stream_config.sample_rate_hz(), stream_config.num_channels());
    
    handle->aec_audio = std::make_unique<AudioBuffer>(
        stream_config.sample_rate_hz(), stream_config.num_channels(),
        stream_config.sample_rate_hz(), stream_config.num_channels(),
        stream_config.sample_rate_hz(), stream_config.num_channels());

    if (config->export_linear) {
        constexpr int kLinearOutputRateHz = 16000;
        handle->aec_linear_audio = std::make_unique<AudioBuffer>(
            kLinearOutputRateHz, stream_config.num_channels(),
            kLinearOutputRateHz, stream_config.num_channels(),
            kLinearOutputRateHz, stream_config.num_channels());
    }

    return handle;
}

int aec3_process_frame(
    aec3_handle_t* handle,
    const int16_t* reference_frame,
    const int16_t* capture_frame,
    int16_t* output_frame,
    int16_t* linear_output_frame,
    size_t frame_size,
    int buffer_delay) {
    
    if (!handle || !reference_frame || !capture_frame || !output_frame) {
        return -1;
    }

    // Update frames with new audio data
    handle->ref_frame.UpdateFrame(0, const_cast<int16_t*>(reference_frame),
        frame_size, handle->sample_rate,
        AudioFrame::kNormalSpeech, AudioFrame::kVadActive, 1);
    
    handle->aec_frame.UpdateFrame(0, const_cast<int16_t*>(capture_frame),
        frame_size, handle->sample_rate,
        AudioFrame::kNormalSpeech, AudioFrame::kVadActive, 1);

    // Copy frames to audio buffers
    handle->ref_audio->CopyFrom(&handle->ref_frame);
    handle->aec_audio->CopyFrom(&handle->aec_frame);

    // Process audio
    handle->ref_audio->SplitIntoFrequencyBands();
    handle->echo_controller->AnalyzeRender(handle->ref_audio.get());
    handle->ref_audio->MergeFrequencyBands();
    
    handle->echo_controller->AnalyzeCapture(handle->aec_audio.get());
    handle->aec_audio->SplitIntoFrequencyBands();
    handle->hp_filter->Process(handle->aec_audio.get(), true);
    
    // Use the buffer_delay parameter instead of hardcoded value
    handle->echo_controller->SetAudioBufferDelay(buffer_delay);
    
    if (handle->aec_linear_audio) {
        handle->echo_controller->ProcessCapture(
            handle->aec_audio.get(), handle->aec_linear_audio.get(), false);
    } else {
        handle->echo_controller->ProcessCapture(
            handle->aec_audio.get(), nullptr, false);
    }
    
    handle->aec_audio->MergeFrequencyBands();

    // Copy processed audio back to output
    handle->aec_audio->CopyTo(&handle->aec_frame);
    memcpy(output_frame, handle->aec_frame.data(),
        frame_size * handle->num_channels * sizeof(int16_t));

    // Copy linear output if requested
    if (linear_output_frame && handle->aec_linear_audio) {
        constexpr int kLinearOutputRateHz = 16000;
        handle->aec_frame.UpdateFrame(0, nullptr,
            kLinearOutputRateHz / 100, kLinearOutputRateHz,
            AudioFrame::kNormalSpeech, AudioFrame::kVadActive, 1);
        handle->aec_linear_audio->CopyTo(&handle->aec_frame);
        memcpy(linear_output_frame, handle->aec_frame.data(), 320);
    }

    return 0;
}

void aec3_destroy(aec3_handle_t* handle) {
    delete handle;
} 