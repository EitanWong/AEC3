using System;
using System.Runtime.InteropServices;

namespace AEC3
{
    /// <summary>
    /// Configuration structure for AEC3
    /// </summary>
    [StructLayout(LayoutKind.Sequential)]
    public struct AEC3Config
    {
        public int SampleRate;      // Sample rate in Hz
        public int NumChannels;     // Number of channels
        public int ExportLinear;    // Whether to export linear AEC output (0 = false, 1 = true)
    }

    /// <summary>
    /// P/Invoke declarations for the AEC3 native library
    /// </summary>
    internal static class AEC3Native
    {
        // Platform-specific library name
        private const string LibName = "aec3";
        
        // For macOS ARM64, this automatically looks for libaec3.dylib or aec.dylib
        // For other platforms, modify this as needed
        static AEC3Native()
        {
            NativeLibrary.SetDllImportResolver(typeof(AEC3Native).Assembly, ImportResolver);
        }

        private static IntPtr ImportResolver(string libraryName, System.Reflection.Assembly assembly, DllImportSearchPath? searchPath)
        {
            if (libraryName != LibName)
                return IntPtr.Zero;

            IntPtr handle = IntPtr.Zero;
            
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                // Try the original library name first
                if (NativeLibrary.TryLoad($"{libraryName}.dylib", out handle))
                    return handle;
                
                // Then try with lib prefix
                if (NativeLibrary.TryLoad($"lib{libraryName}.dylib", out handle))
                    return handle;
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                if (NativeLibrary.TryLoad($"lib{libraryName}.so", out handle))
                    return handle;
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                // Try architecture-specific names first
                if (RuntimeInformation.ProcessArchitecture == Architecture.X64)
                {
                    if (NativeLibrary.TryLoad($"{libraryName}_x64.dll", out handle))
                        return handle;
                }
                else if (RuntimeInformation.ProcessArchitecture == Architecture.X86)
                {
                    if (NativeLibrary.TryLoad($"{libraryName}_x86.dll", out handle))
                        return handle;
                }
                
                // Then try generic name
                if (NativeLibrary.TryLoad($"{libraryName}.dll", out handle))
                    return handle;
            }

            // Fallback to default behavior
            return IntPtr.Zero;
        }

        // Handle for the AEC3 instance (opaque pointer)
        [StructLayout(LayoutKind.Sequential)]
        internal struct AEC3Handle { IntPtr handle; }

        /// <summary>
        /// Create a new AEC3 instance
        /// </summary>
        [DllImport(LibName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern IntPtr aec3_create(ref AEC3Config config);

        /// <summary>
        /// Process a frame of audio
        /// </summary>
        /// <returns>0 on success, non-zero on error</returns>
        [DllImport(LibName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern int aec3_process_frame(
            IntPtr handle,
            [In] short[] referenceFrame,    // Reference (far-end) audio
            [In] short[] captureFrame,      // Capture (near-end) audio
            [Out] short[] outputFrame,      // Processed output
            [Out] short[] linearOutputFrame, // Linear AEC output (can be null if not enabled)
            IntPtr frameSize,                // Number of samples per channel
            int bufferDelay = 0             // Optional audio buffer delay in samples
        );

        /// <summary>
        /// Destroy an AEC3 instance
        /// </summary>
        [DllImport(LibName, CallingConvention = CallingConvention.Cdecl)]
        internal static extern void aec3_destroy(IntPtr handle);
    }
} 