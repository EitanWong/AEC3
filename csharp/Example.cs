using System;
using System.IO;
using gccphat_core;

namespace AEC3
{
    class Example
    {
        static void PrintWavInformation(string fileName, int format, int channels, int sampleRate, int bitsPerSample, uint dataLength)
        {
            Console.WriteLine("=====================================");
            Console.WriteLine($"{fileName} information:");
            Console.WriteLine($"format: {format}");
            Console.WriteLine($"channels: {channels}");
            Console.WriteLine($"sample_rate: {sampleRate}");
            Console.WriteLine($"bits_per_sample: {bitsPerSample}");
            Console.WriteLine($"length: {dataLength}");
            Console.WriteLine($"total_samples: {dataLength / (bitsPerSample / 8)}");
            Console.WriteLine("=====================================");
        }

        static void PrintProgress(int current, int total)
        {
            int percentage = (int)(current / (float)total * 100);
            const int progressBarLength = 50;
            int progress = percentage * progressBarLength / 100;
            
            Console.Write($"        {current}/{total}    {percentage}%|");
            
            for (int i = 0; i < progress; i++)
                Console.Write("=");
                
            Console.Write(">");
            
            for (int i = progress; i < progressBarLength; i++)
                Console.Write(" ");
                
            Console.Write("|\r");
        }
        
        static short[] GenerateTestSineWave(int sampleRate, int channels, double frequency, double duration, double amplitude)
        {
            int samples = (int)(sampleRate * duration);
            short[] buffer = new short[samples * channels];
            
            for (int i = 0; i < samples; i++)
            {
                double time = i / (double)sampleRate;
                short value = (short)(amplitude * Math.Sin(2 * Math.PI * frequency * time));
                
                for (int ch = 0; ch < channels; ch++)
                {
                    buffer[i * channels + ch] = value;
                }
            }
            
            return buffer;
        }

        static int CalculateAudioBufferDelay(short[] refData, short[] recData, int sampleRate, int channels)
        {
            // Default parameters for GccPhat
            int fmin = 300;
            int fmax = 3000;

            // For best results with FFT, use a power of 2 for frame size
            int frameSize = 2048;
            
            // Convert data to double arrays for processing
            double[] refDouble = new double[frameSize];
            double[] recDouble = new double[frameSize];
            
            // Use only the first channel if we have stereo audio
            for (int i = 0; i < frameSize; i++)
            {
                if (i < refData.Length)
                {
                    refDouble[i] = channels == 1 ? 
                        refData[i] : 
                        refData[Math.Min(i * 2, refData.Length - 1)];
                }
                
                if (i < recData.Length)
                {
                    recDouble[i] = channels == 1 ? 
                        recData[i] : 
                        recData[Math.Min(i * 2, recData.Length - 1)];
                }
            }
            
            // Calculate delay using GccPhat
            var (timeDelayMs, _) = GccPhatCore.GCCPHAT(refDouble, recDouble, sampleRate, 1, fmin, fmax);
            
            // Convert delay from milliseconds to samples
            int delaySamples = (int)Math.Round(timeDelayMs * sampleRate / 1000.0);
            
            Console.WriteLine($"Detected delay: {timeDelayMs:F2} ms ({delaySamples} samples)");
            
            return delaySamples;
        }
        
        static void UpdateDelayEstimation(short[] refData, short[] recData, int sampleRate, int channels, ref int audioBufferDelay)
        {
            // Process in chunks to provide real-time-like behavior
            int chunkSize = 4096; // Use a larger chunk for more accurate delay estimation
            int totalChunks = Math.Min(refData.Length, recData.Length) / (chunkSize * channels);
            int totalDelayEstimates = 0;
            int sumDelayEstimates = 0;
            
            Console.WriteLine("Estimating audio buffer delay...");
            
            for (int chunk = 0; chunk < totalChunks; chunk += 2) // Process every other chunk to save time
            {
                int offset = chunk * chunkSize * channels;
                short[] refChunk = new short[chunkSize * channels];
                short[] recChunk = new short[chunkSize * channels];
                
                Array.Copy(refData, offset, refChunk, 0, chunkSize * channels);
                Array.Copy(recData, offset, recChunk, 0, chunkSize * channels);
                
                int delayEstimate = CalculateAudioBufferDelay(refChunk, recChunk, sampleRate, channels);
                
                // Add to running average if delay estimate seems reasonable (not extreme outliers)
                if (Math.Abs(delayEstimate) < sampleRate / 2) // Limit to half a second of delay
                {
                    sumDelayEstimates += delayEstimate;
                    totalDelayEstimates++;
                }
                
                // Show progress
                PrintProgress(chunk + 1, totalChunks);
            }
            
            if (totalDelayEstimates > 0)
            {
                // Calculate average delay
                audioBufferDelay = sumDelayEstimates / totalDelayEstimates;
                Console.WriteLine($"\nEstimated audio buffer delay: {audioBufferDelay} samples ({audioBufferDelay * 1000.0 / sampleRate:F2} ms)");
            }
            else
            {
                Console.WriteLine("\nCould not reliably estimate audio buffer delay. Using default value.");
            }
        }

        static void Main(string[] args)
        {
            // Parse command-line arguments or use defaults
            string refFile = "ref.wav";
            string recFile = "rec.wav";
            string outFile = "out.wav";
            
            bool useTestData = false;
            int sampleRate = 16000;
            int numChannels = 1;
            int audioBufferDelay = 0;
            bool autoDetectDelay = false;
            
            // Process command line arguments
            for (int i = 0; i < args.Length; i++)
            {
                if (i == 0 && !args[i].StartsWith("--"))
                {
                    refFile = args[i];
                }
                else if (i == 1 && !args[i].StartsWith("--"))
                {
                    recFile = args[i];
                }
                else if (i == 2 && !args[i].StartsWith("--"))
                {
                    outFile = args[i];
                }
                else if (args[i] == "--test")
                {
                    useTestData = true;
                }
                else if (args[i] == "--delay" && i + 1 < args.Length)
                {
                    if (int.TryParse(args[i + 1], out int delay))
                    {
                        audioBufferDelay = delay;
                        i++; // Skip the next argument since we've processed it
                    }
                    else
                    {
                        Console.Error.WriteLine($"Invalid delay value: {args[i + 1]}");
                    }
                }
                else if (args[i] == "--auto-delay")
                {
                    autoDetectDelay = true;
                }
            }
            
            Console.WriteLine("======================================");
            Console.WriteLine($"ref file is: {refFile}");
            Console.WriteLine($"rec file is: {recFile}");
            Console.WriteLine($"out file is: {outFile}");
            Console.WriteLine($"Audio buffer delay: {(autoDetectDelay ? "AUTO" : audioBufferDelay.ToString())} samples");
            if (useTestData)
                Console.WriteLine("Using generated test data");
            Console.WriteLine("======================================");

            // Variables to hold audio data
            short[] refData = null;
            short[] recData = null;
            int refFormat = 1; // PCM format
            int refChannels = numChannels;
            int refSampleRate = sampleRate;
            int refBitsPerSample = 16;
            uint refDataLength = 0;
            
            // Try to load WAV files if not using test data
            if (!useTestData)
            {
                try
                {
                    // Open reference and recorded WAV files
                    WAV_file refWav = new WAV_file(Path.GetDirectoryName(refFile) ?? ".", Path.GetFileName(refFile));
                    WAV_file recWav = new WAV_file(Path.GetDirectoryName(recFile) ?? ".", Path.GetFileName(recFile));

                    // Load WAV files
                    refWav.loadFile();
                    recWav.loadFile();

                    // Get reference file properties
                    refChannels = (int)refWav.NumOfChannels;
                    refSampleRate = (int)refWav.SampleRate;
                    refBitsPerSample = (int)refWav.BitsPerSample;
                    
                    // Calculate the data length in bytes
                    refDataLength = refWav.NumberOfSamples * (uint)(refBitsPerSample / 8);

                    PrintWavInformation(refFile, refFormat, refChannels, refSampleRate, refBitsPerSample, refDataLength);

                    // Get recorded file properties
                    int recFormat = 1; // PCM format
                    int recChannels = (int)recWav.NumOfChannels;
                    int recSampleRate = (int)recWav.SampleRate;
                    int recBitsPerSample = (int)recWav.BitsPerSample;
                    uint recDataLength = recWav.NumberOfSamples * (uint)(recBitsPerSample / 8);

                    PrintWavInformation(recFile, recFormat, recChannels, recSampleRate, recBitsPerSample, recDataLength);

                    // Check that formats match
                    if (refFormat != recFormat ||
                        refChannels != recChannels ||
                        refSampleRate != recSampleRate ||
                        refBitsPerSample != recBitsPerSample)
                    {
                        Console.Error.WriteLine("ref file format != rec file format");
                        useTestData = true;
                    }
                    else
                    {
                        // Get the audio data from the WAV files
                        if (recChannels == (int)WAV_file.NUM_CHANNELS.ONE)
                        {
                            refWav.getBuffer_16_bits_mono(out refData);
                            recWav.getBuffer_16_bits_mono(out recData);
                        }
                        else
                        {
                            short[] leftRef, rightRef, leftRec, rightRec;
                            refWav.getBuffer_16_bits_stereo(out leftRef, out rightRef);
                            recWav.getBuffer_16_bits_stereo(out leftRec, out rightRec);
                            
                            // Interleave the channels for stereo
                            refData = new short[leftRef.Length * 2];
                            recData = new short[leftRec.Length * 2];
                            
                            for (int i = 0; i < leftRef.Length; i++)
                            {
                                refData[i * 2] = leftRef[i];
                                refData[i * 2 + 1] = rightRef[i];
                                recData[i * 2] = leftRec[i];
                                recData[i * 2 + 1] = rightRec[i];
                            }
                        }
                        
                        // Auto-detect delay if requested
                        if (autoDetectDelay)
                        {
                            UpdateDelayEstimation(refData, recData, refSampleRate, refChannels, ref audioBufferDelay);
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine($"Error loading WAV files: {ex.Message}");
                    Console.Error.WriteLine("Switching to generated test data.");
                    useTestData = true;
                }
            }
            
            // Generate test data if needed
            if (useTestData)
            {
                refSampleRate = 16000;
                refChannels = 1;
                refBitsPerSample = 16;
                
                // Generate 3 seconds of audio
                double duration = 3.0;
                
                // Generate a pure sine wave at 1000 Hz for reference
                refData = GenerateTestSineWave(refSampleRate, refChannels, 1000, duration, short.MaxValue * 0.5);
                
                // Generate a mixed signal with the reference plus some noise for capture
                recData = new short[refData.Length];
                Array.Copy(refData, recData, refData.Length);
                
                // Add echo and noise to the capture signal
                Random rng = new Random(42);
                for (int i = 0; i < recData.Length; i++)
                {
                    // Add echo with delay and attenuation
                    int delayInSamples = refSampleRate / 4; // 250ms delay
                    if (i >= delayInSamples)
                    {
                        recData[i] += (short)(refData[i - delayInSamples] * 0.7); // 70% echo
                    }
                    
                    // Add some random noise (20% of max amplitude)
                    recData[i] += (short)(rng.NextDouble() * short.MaxValue * 0.2 - short.MaxValue * 0.1);
                    
                    // Ensure we don't exceed the range
                    recData[i] = Math.Clamp(recData[i], short.MinValue, short.MaxValue);
                }
                
                refDataLength = (uint)(refData.Length * sizeof(short));
                
                Console.WriteLine("Generated test data:");
                PrintWavInformation("Generated reference", refFormat, refChannels, refSampleRate, refBitsPerSample, refDataLength);
                
                // Auto-detect delay in test data if requested
                if (autoDetectDelay)
                {
                    UpdateDelayEstimation(refData, recData, refSampleRate, refChannels, ref audioBufferDelay);
                }
            }

            // Create AEC3 instance
            using (var aec = new AEC3Processor(refSampleRate, refChannels, true))
            {
                Console.WriteLine("AEC3 processor created successfully.");

                // Prepare output WAV files
                WAV_file outWav = new WAV_file(".", outFile);
                WAV_file linearOutWav = new WAV_file(".", "linear.wav");

                // Configure output files
                outWav.SampleRate = (uint)refSampleRate;
                outWav.NumOfChannels = (WAV_file.NUM_CHANNELS)refChannels;
                outWav.BitsPerSample = (WAV_file.BITS_PER_SAMPLE)refBitsPerSample;

                linearOutWav.SampleRate = 16000; // Linear output at 16kHz
                linearOutWav.NumOfChannels = (WAV_file.NUM_CHANNELS)refChannels;
                linearOutWav.BitsPerSample = (WAV_file.BITS_PER_SAMPLE)refBitsPerSample;

                // Calculate samples per frame (10ms)
                int samplesPerFrame = refSampleRate / 100;
                int framesTotal = refData.Length / (samplesPerFrame * refChannels);

                // Allocate audio buffers
                short[] refBuffer = new short[samplesPerFrame * refChannels];
                short[] recBuffer = new short[samplesPerFrame * refChannels];
                short[] outputBuffer = new short[samplesPerFrame * refChannels];
                short[] linearOutputBuffer = new short[160]; // 16000 / 100 = 160 samples for 10ms at 16kHz

                // Prepare output buffers
                short[] outputData = new short[refData.Length];
                short[] linearOutputData = new short[160 * framesTotal]; // Linear output at 16kHz
                
                // Process audio frames
                Console.WriteLine("Processing audio frames ...");
                for (int current = 0; current < framesTotal; current++)
                {
                    PrintProgress(current + 1, framesTotal);
                    
                    // Copy frame data
                    int frameOffset = current * samplesPerFrame * refChannels;
                    Array.Copy(refData, frameOffset, refBuffer, 0, Math.Min(refBuffer.Length, refData.Length - frameOffset));
                    Array.Copy(recData, frameOffset, recBuffer, 0, Math.Min(recBuffer.Length, recData.Length - frameOffset));
                    
                    // Process frame with audio buffer delay
                    bool success = aec.ProcessFrame(
                        refBuffer,
                        recBuffer,
                        outputBuffer,
                        linearOutputBuffer,
                        audioBufferDelay
                    );
                    
                    if (!success)
                    {
                        Console.Error.WriteLine("Error processing frame");
                        break;
                    }
                    
                    // Save the processed output
                    Array.Copy(outputBuffer, 0, outputData, frameOffset, Math.Min(outputBuffer.Length, outputData.Length - frameOffset));
                    Array.Copy(linearOutputBuffer, 0, linearOutputData, current * 160, Math.Min(160, linearOutputData.Length - current * 160));
                }
                
                Console.WriteLine("\nProcessing complete!");
                
                // Save output files
                if (refChannels == (int)WAV_file.NUM_CHANNELS.ONE)
                {
                    outWav.NumberOfSamples = (uint)outputData.Length;
                    outWav.initializeWaveHeaderStructBeforeWriting();
                    outWav.setBuffer_16_bits_mono(outputData);
                    
                    linearOutWav.NumberOfSamples = (uint)linearOutputData.Length;
                    linearOutWav.initializeWaveHeaderStructBeforeWriting();
                    linearOutWav.setBuffer_16_bits_mono(linearOutputData);
                }
                else
                {
                    // Split interleaved stereo data
                    short[] leftOut = new short[outputData.Length / 2];
                    short[] rightOut = new short[outputData.Length / 2];
                    short[] leftLinear = new short[linearOutputData.Length / 2];
                    short[] rightLinear = new short[linearOutputData.Length / 2];
                    
                    for (int i = 0; i < outputData.Length / 2; i++)
                    {
                        leftOut[i] = outputData[i * 2];
                        rightOut[i] = outputData[i * 2 + 1];
                    }
                    
                    for (int i = 0; i < linearOutputData.Length / 2; i++)
                    {
                        leftLinear[i] = linearOutputData[i * 2];
                        rightLinear[i] = linearOutputData[i * 2 + 1];
                    }
                    
                    outWav.NumberOfSamples = (uint)(outputData.Length / 2);
                    outWav.initializeWaveHeaderStructBeforeWriting();
                    outWav.setBuffer_16_bits_stereo(leftOut, rightOut);
                    
                    linearOutWav.NumberOfSamples = (uint)(linearOutputData.Length / 2);
                    linearOutWav.initializeWaveHeaderStructBeforeWriting();
                    linearOutWav.setBuffer_16_bits_stereo(leftLinear, rightLinear);
                }
                
                // Write the output files
                outWav.writeFile();
                linearOutWav.writeFile();
                
                Console.WriteLine($"Output written to {outFile} and linear.wav");
            }
        }
    }
} 