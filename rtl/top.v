// ============================================================
// top.v — ECG signal processing top-level
// ============================================================
`timescale 1ns/1ps
module top(
    input  wire clk,
    input  wire rst,
    input  wire signed [15:0] sample_in,
    output wire signed [15:0] filtered_out,
    output wire signed [31:0] mwi_out,
    output wire               r_peak,
    output wire [15:0]        heart_rate,
    output wire [31:0]        sample_index_out
);

  // ==========================================================
  // Sample index counter
  // ==========================================================
  reg [31:0] sample_index = 0;
  always @(posedge clk) begin
    if (rst)
      sample_index <= 0;
    else
      sample_index <= sample_index + 1;
  end
  assign sample_index_out = sample_index;

  // ==========================================================
  // Signal chain
  // ==========================================================
  wire signed [15:0] der_out;
  wire signed [15:0] hp_out;
  wire signed [31:0] sq_out;
  wire signed [31:0] mwi_sig;
  wire signed [31:0] peak_val;
  wire [31:0] rr_interval;

  // Example module instances — adjust ports if yours differ
  derivative u_derivative (
    .clk(clk),
    .rst(rst),
    .in(sample_in),
    .out(der_out)
  );

  hp_filter u_hp_filter (
    .clk(clk),
    .rst(rst),
    .in(der_out),
    .out(hp_out)
  );

  squaring u_squaring (
    .clk(clk),
    .rst(rst),
    .in(hp_out),
    .out(sq_out)
  );

  mwi #(.INW(32), .OUTW(32), .WIN(32)) u_mwi (
    .clk(clk),
    .rst(rst),
    .in(sq_out),
    .out(mwi_sig)
  );

  peak_detector #(.INW(32), .FS(250)) u_peak_detector (
    .clk(clk),
    .rst(rst),
    .in(mwi_sig),
    .sample_index(sample_index),
    .r_peak(r_peak),
    .peak_value(peak_val)
  );

  metrics #(.FS(250)) u_metrics (
    .clk(clk),
    .rst(rst),
    .r_peak(r_peak),
    .sample_index(sample_index),
    .rr_samples(rr_interval),
    .heart_rate(heart_rate)
  );

  // Assign outputs
  assign filtered_out = hp_out;
  assign mwi_out      = mwi_sig;

endmodule
