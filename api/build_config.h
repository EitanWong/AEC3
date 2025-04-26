#ifndef BUILD_CONFIG_H_
#define BUILD_CONFIG_H_

// Platform detection
#if defined(__APPLE__)
#define WEBRTC_MAC 1
#define WEBRTC_POSIX 1
#elif defined(_WIN32)
#define WEBRTC_WIN 1
#elif defined(__linux__)
#define WEBRTC_LINUX 1
#define WEBRTC_POSIX 1
#elif defined(__ANDROID__)
#define WEBRTC_ANDROID 1
#define WEBRTC_POSIX 1
#elif defined(__IOS__)
#define WEBRTC_IOS 1
#define WEBRTC_POSIX 1
#endif

// Architecture detection
#if defined(__x86_64__) || defined(_M_X64)
#define WEBRTC_ARCH_X86_FAMILY 1
#define WEBRTC_ARCH_X86_64 1
#elif defined(__i386__) || defined(_M_IX86)
#define WEBRTC_ARCH_X86_FAMILY 1
#define WEBRTC_ARCH_X86 1
#elif defined(__aarch64__) || defined(_M_ARM64)
#define WEBRTC_ARCH_ARM_FAMILY 1
#define WEBRTC_ARCH_ARM64 1
#elif defined(__arm__) || defined(_M_ARM)
#define WEBRTC_ARCH_ARM_FAMILY 1
#define WEBRTC_ARCH_ARM 1
#endif

// Feature flags
#define WEBRTC_APM_DEBUG_DUMP 0
#define WEBRTC_ENABLE_PROTOBUF 0
#define WEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE 1
#define WEBRTC_USE_BUILTIN_ISAC_FIX 0
#define WEBRTC_USE_BUILTIN_ISAC_FLOAT 1
#define WEBRTC_USE_BUILTIN_OPUS 1
#define WEBRTC_USE_BUILTIN_ILBC 1
#define WEBRTC_USE_BUILTIN_G722 1
#define WEBRTC_USE_BUILTIN_NEON 1
#define WEBRTC_USE_BUILTIN_SSE2 1
#define WEBRTC_USE_BUILTIN_SSE3 1
#define WEBRTC_USE_BUILTIN_SSSE3 1
#define WEBRTC_USE_BUILTIN_SSE4_1 1
#define WEBRTC_USE_BUILTIN_AVX2 1

#endif  // BUILD_CONFIG_H_ 