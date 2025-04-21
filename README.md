# AEC3
AEC3 Extracted From WebRTC

This is a build adaptation for macOS Apple Silicon platform of the original project: [ewan-xu/AEC3](https://github.com/ewan-xu/AEC3)

## Build

### Windows
- Visual Studio 2015

### macOS (Apple Silicon/ARM)
#### Prerequisites
1. Install Homebrew (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install required packages:
   ```bash
   brew install cmake
   ```

#### Build Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/EitanWong/AEC3.git
   cd AEC3
   ```

2. Build using the provided script:
   ```bash
   cd demo
   chmod +x build.sh
   ./build.sh
   ```

   Or manually:
   ```bash
   cd demo
   mkdir -p build
   cd build
   cmake ..
   make -j$(sysctl -n hw.ncpu)
   ```

## Usage
The demo application processes audio files for acoustic echo cancellation:

```bash
./demo ref.wav rec.wav out.wav
```

Where:
- `ref.wav`: Reference/far-end signal (e.g., audio played from speakers)
- `rec.wav`: Recorded/near-end signal (e.g., microphone recording with echo)
- `out.wav`: Output file where the processed audio (echo-cancelled) will be saved

## Test
See demo.cc for example usage.

## Note
The AEC3 (Acoustic Echo Cancellation) implementation is extracted from the WebRTC project and adapted to run as a standalone library. This repository contains build scripts specifically for macOS Apple Silicon platform.
