// metrics.v
`timescale 1ns/1ps
module metrics #(
  parameter FS = 250 // sampling frequency in Hz (set to actual sample rate)
)(
  input  wire clk,
  input  wire rst,
  input  wire r_peak,
  input  wire [31:0] sample_index,
  output reg [31:0] rr_samples,
  output reg [15:0] heart_rate   // integer BPM
);
  reg [31:0] last_peak_sample;

  always @(posedge clk) begin
    if (rst) begin
      last_peak_sample <= 32'd0;
      rr_samples <= 32'd0;
      heart_rate <= 16'd0;
    end else begin
      if (r_peak) begin
        if (last_peak_sample != 0) begin
          rr_samples <= sample_index - last_peak_sample;
          if ((sample_index - last_peak_sample) != 0) begin
            // heart rate = 60 * FS / RR_samples
            heart_rate <= (60 * FS) / (sample_index - last_peak_sample);
          end else begin
            heart_rate <= 16'd0;
          end
        end
        last_peak_sample <= sample_index;
      end
    end
  end
endmodule
