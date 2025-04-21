/*
 *  Copyright (c) 2019 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "audio_processing/utility/pffft_wrapper.h"

#include "rtc_base/checks.h"

namespace webrtc {

PffftWrapper::PffftWrapper(int fft_size, bool is_real)
    : fft_size_(fft_size), is_real_(is_real) {
  RTC_CHECK_GT(fft_size, 0);
  fft_ = std::make_unique<OouraFft>();
}

PffftWrapper::~PffftWrapper() = default;

void PffftWrapper::ForwardTransform(rtc::ArrayView<const float> input,
                                  rtc::ArrayView<float> output) {
  RTC_CHECK_EQ(input.size(), fft_size_);
  RTC_CHECK_EQ(output.size(), fft_size_);
  std::copy(input.begin(), input.end(), output.begin());
  fft_->Fft(output.data());
}

void PffftWrapper::InverseTransform(rtc::ArrayView<const float> input,
                                  rtc::ArrayView<float> output) {
  RTC_CHECK_EQ(input.size(), fft_size_);
  RTC_CHECK_EQ(output.size(), fft_size_);
  std::copy(input.begin(), input.end(), output.begin());
  fft_->InverseFft(output.data());
}

}  // namespace webrtc
