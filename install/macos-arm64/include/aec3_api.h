#ifndef AEC_API_H
#define AEC_API_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Handle for the AEC instance
typedef struct aec3_handle aec3_handle_t;

// Configuration structure
typedef struct {
    int sample_rate;      // Sample rate in Hz
    int num_channels;     // Number of channels
    int export_linear;    // Whether to export linear AEC output
} aec3_config_t;

// Create a new AEC3 instance
aec3_handle_t* aec3_create(const aec3_config_t* config);

// Process a frame of audio
// Returns 0 on success, non-zero on error
int aec3_process_frame(
    aec3_handle_t* handle,
    const int16_t* reference_frame,  // Reference (far-end) audio
    const int16_t* capture_frame,    // Capture (near-end) audio
    int16_t* output_frame,           // Processed output
    int16_t* linear_output_frame,    // Linear AEC output (if enabled)
    size_t frame_size,               // Number of samples per channel
    int buffer_delay                 // Audio buffer delay in samples
);

// Destroy an AEC3 instance
void aec3_destroy(aec3_handle_t* handle);

#ifdef __cplusplus
}
#endif

#endif // AEC_API_H 