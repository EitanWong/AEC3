#include <cstdio>
#include <cstdint>
#include <cstddef>

namespace webrtc {

// Constants for SincResampler (if needed)
const size_t kKernelSize = 32;

// Forward declarations for SincResampler class
class SincResampler {
public:
    static float Convolve_SSE(const float* input_ptr,
                              const float* k1,
                              const float* k2,
                              double kernel_interpolation_factor);
};

// SincResampler SIMD stub
float SincResampler::Convolve_SSE(const float* input_ptr,
                                 const float* k1,
                                 const float* k2,
                                 double kernel_interpolation_factor) {
    fprintf(stderr, "Warning: Using non-SIMD stub for SincResampler::Convolve_SSE\n");
    
    // Fallback implementation that does the same calculation without SIMD
    float sum1 = 0.0f;
    float sum2 = 0.0f;
    
    for (size_t i = 0; i < kKernelSize; ++i) {
        sum1 += input_ptr[i] * k1[i];
        sum2 += input_ptr[i] * k2[i];
    }
    
    // Linearly interpolate the two "convolutions"
    return (1.0 - kernel_interpolation_factor) * sum1 + kernel_interpolation_factor * sum2;
}

// OouraFft SIMD stubs
void cft1st_128_SSE2(float* a) {
    fprintf(stderr, "Warning: Using non-SIMD stub for cft1st_128_SSE2\n");
    // No-op stub
}

void cftmdl_128_SSE2(float* a) {
    fprintf(stderr, "Warning: Using non-SIMD stub for cftmdl_128_SSE2\n");
    // No-op stub
}

void rftbsub_128_SSE2(float* a) {
    fprintf(stderr, "Warning: Using non-SIMD stub for rftbsub_128_SSE2\n");
    // No-op stub
}

void rftfsub_128_SSE2(float* a) {
    fprintf(stderr, "Warning: Using non-SIMD stub for rftfsub_128_SSE2\n");
    // No-op stub
}

} // namespace webrtc 