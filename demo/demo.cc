#include "api/aec3_api.h"
#include "wavreader.h"
#include "wavwriter.h"
#include <iostream>
#include <memory>

void print_wav_information(const char* fn, int format, int channels, int sample_rate, int bits_per_sample, int length) {
    std::cout << "=====================================" << std::endl
        << fn << " information:" << std::endl
        << "format: " << format << std::endl
        << "channels: " << channels << std::endl
        << "sample_rate: " << sample_rate << std::endl
        << "bits_per_sample: " << bits_per_sample << std::endl
        << "length: " << length << std::endl
        << "total_samples: " << length / bits_per_sample * 8 << std::endl
        << "======================================" << std::endl;
}

void print_progress(int current, int total) {
    int percentage = current / static_cast<float>(total) * 100;
    static constexpr int p_bar_length = 50;
    int progress = percentage * p_bar_length / 100;
    std::cout << "        " << current << "/" << total << "    " << percentage << "%";
    std::cout << "|";
    for (int i = 0; i < progress; ++i)
        std::cout << "=";
    std::cout << ">";
    for (int i = progress; i < p_bar_length; ++i)
        std::cout << " ";
    std::cout << "|";
    std::cout << "\r";
}

int main(int argc, char* argv[]) {
    if (argc != 4) {
        std::cerr << "usage: ./simple_demo ref.wav rec.wav out.wav" << std::endl;
        return -1;
    }

    std::cout << "======================================" << std::endl
        << "ref file is: " << argv[1] << std::endl
        << "rec file is: " << argv[2] << std::endl
        << "out file is: " << argv[3] << std::endl
        << "======================================" << std::endl;

    void* h_ref = wav_read_open(argv[1]);
    void* h_rec = wav_read_open(argv[2]);

    int ref_format, ref_channels, ref_sample_rate, ref_bits_per_sample;
    int rec_format, rec_channels, rec_sample_rate, rec_bits_per_sample;
    unsigned int ref_data_length, rec_data_length;

    int res = wav_get_header(h_ref, &ref_format, &ref_channels, &ref_sample_rate, &ref_bits_per_sample, &ref_data_length);
    if (!res) {
        std::cerr << "get ref header error: " << res << std::endl;
        return -1;
    }
    int ref_samples = ref_data_length * 8 / ref_bits_per_sample;
    print_wav_information(argv[1], ref_format, ref_channels, ref_sample_rate, ref_bits_per_sample, ref_data_length);

    res = wav_get_header(h_rec, &rec_format, &rec_channels, &rec_sample_rate, &rec_bits_per_sample, &rec_data_length);
    if (!res) {
        std::cerr << "get rec header error: " << res << std::endl;
        return -1;
    }
    int rec_samples = rec_data_length * 8 / rec_bits_per_sample;
    print_wav_information(argv[2], rec_format, rec_channels, rec_sample_rate, rec_bits_per_sample, rec_data_length);

    if (ref_format != rec_format ||
        ref_channels != rec_channels ||
        ref_sample_rate != rec_sample_rate ||
        ref_bits_per_sample != rec_bits_per_sample) {
        std::cerr << "ref file format != rec file format" << std::endl;
        return -1;
    }

    // Create AEC3 instance
    aec3_config_t config = {
        .sample_rate = rec_sample_rate,
        .num_channels = rec_channels,
        .export_linear = true
    };
    aec3_handle_t* aec3 = aec3_create(&config);
    if (!aec3) {
        std::cerr << "Failed to create AEC3 instance" << std::endl;
        return -1;
    }

    void* h_out = wav_write_open(argv[3], rec_sample_rate, rec_bits_per_sample, rec_channels);
    void* h_linear_out = wav_write_open("linear.wav", 16000, rec_bits_per_sample, rec_channels);

    int samples_per_frame = rec_sample_rate / 100;
    int bytes_per_frame = samples_per_frame * rec_bits_per_sample / 8;
    int total = rec_samples < ref_samples ? rec_samples / samples_per_frame : rec_samples / samples_per_frame;

    int current = 0;
    std::unique_ptr<unsigned char[]> ref_tmp(new unsigned char[bytes_per_frame]);
    std::unique_ptr<unsigned char[]> aec_tmp(new unsigned char[bytes_per_frame]);
    std::unique_ptr<int16_t[]> output_frame(new int16_t[samples_per_frame * rec_channels]);
    std::unique_ptr<int16_t[]> linear_output_frame(new int16_t[160]);

    std::cout << "processing audio frames ..." << std::endl;
    while (current++ < total) {
        print_progress(current, total);
        wav_read_data(h_ref, ref_tmp.get(), bytes_per_frame);
        wav_read_data(h_rec, aec_tmp.get(), bytes_per_frame);

        // Process frame
        int ret = aec3_process_frame(
            aec3,
            reinterpret_cast<int16_t*>(ref_tmp.get()),
            reinterpret_cast<int16_t*>(aec_tmp.get()),
            output_frame.get(),
            linear_output_frame.get(),
            samples_per_frame
        );

        if (ret != 0) {
            std::cerr << "Error processing frame: " << ret << std::endl;
            break;
        }

        // Write output
        wav_write_data(h_out, reinterpret_cast<unsigned char*>(output_frame.get()), bytes_per_frame);
        wav_write_data(h_linear_out, reinterpret_cast<unsigned char*>(linear_output_frame.get()), 320);
    }

    // Cleanup
    aec3_destroy(aec3);
    wav_read_close(h_ref);
    wav_read_close(h_rec);
    wav_write_close(h_out);
    wav_write_close(h_linear_out);

    return 0;
} 