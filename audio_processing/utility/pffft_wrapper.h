/*
 *  Copyright (c) 2019 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef AUDIO_PROCESSING_UTILITY_PFFFT_WRAPPER_H_
#define AUDIO_PROCESSING_UTILITY_PFFFT_WRAPPER_H_

#include <memory>

#include "rtc_base/array_view.h"
#include "audio_processing/utility/ooura_fft.h"

namespace webrtc {

class PffftWrapper {
 public:
  PffftWrapper(int fft_size, bool is_real);
  ~PffftWrapper();

  void ForwardTransform(rtc::ArrayView<const float> input,
                       rtc::ArrayView<float> output);
  void InverseTransform(rtc::ArrayView<const float> input,
                       rtc::ArrayView<float> output);

 private:
  std::unique_ptr<OouraFft> fft_;
  int fft_size_;
  bool is_real_;
};

}  // namespace webrtc

#endif  // AUDIO_PROCESSING_UTILITY_PFFFT_WRAPPER_H_
