# AEC3 C# Wrapper

This folder contains C# wrapper classes for interacting with the AEC3 acoustic echo cancellation library via P/Invoke.

## Files

- `AEC3Native.cs` - Contains P/Invoke declarations for the native AEC3 API
- `AEC3Processor.cs` - Managed wrapper class that makes the native API easier to use
- `Example.cs` - Example usage of the AEC3 wrapper

## Requirements

- .NET 6.0 or higher (.NET 9.0 recommended)
- Native AEC3 library built for your platform (macOS ARM64 in your case)

## Building and Running

To build and run the example:

```bash
# Navigate to the csharp directory
cd csharp

# Build the project
dotnet build

# Run the example
dotnet run
```

## Usage

1. Build the native AEC3 library following the instructions in the main README
2. Make sure the native library is in your application's runtime directory or in a location where the OS can find it:
   - macOS: `libaec3.dylib` (detected automatically for macOS ARM64)
   - Linux: `libaec3.so` 
   - Windows: `aec3.dll`, `aec3_x64.dll`, or `aec3_x86.dll` depending on architecture
3. Add the C# files to your project
4. Use the `AEC3Processor` class as shown in `Example.cs`

## Basic Example

```csharp
// Create an AEC3 processor
using (var aec = new AEC3Processor(
    sampleRate: 48000,
    numChannels: 1,
    exportLinear: true))
{
    // Allocate audio buffers
    short[] referenceFrame = new short[480]; // 10ms at 48kHz
    short[] captureFrame = new short[480];
    short[] outputFrame = new short[480];
    short[] linearOutputFrame = new short[480];

    // Fill referenceFrame with audio from the far end (e.g., speaker)
    // Fill captureFrame with audio from the near end (e.g., microphone)

    // Process the audio
    bool success = aec.ProcessFrame(
        referenceFrame,
        captureFrame,
        outputFrame,
        linearOutputFrame);

    // Use the processed audio in outputFrame (echo-cancelled audio)
}
```

## Library Loading

The wrapper now includes a custom library resolver that automatically looks for the appropriate library name based on the platform:

- macOS: `libaec3.dylib`
- Linux: `libaec3.so`
- Windows:
  - x64: `aec3_x64.dll`
  - x86: `aec3_x86.dll`
  - Other architectures: `aec3.dll`

## macOS ARM64 Notes

For macOS ARM64 (Apple Silicon), ensure that the native library is built with ARM64 architecture support. The wrapper will automatically look for `libaec3.dylib` when running on macOS.

## Error Handling

The `AEC3Processor.ProcessFrame` method returns a boolean indicating success or failure. If you need more detailed error information, you might need to extend the native API to provide that information. 