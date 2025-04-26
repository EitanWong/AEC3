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
