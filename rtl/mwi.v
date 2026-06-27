// mwi.v
`timescale 1ns/1ps
module mwi #(
  parameter INW = 32,        // width of squared input
  parameter OUTW = 32,       // output width
  parameter WIN = 32         // moving window length (use power-of-two e.g., 32, 64)
)(
  input  wire                   clk,
  input  wire                   rst,
  input  wire signed [INW-1:0]  in,    // squared (positive) input
  output reg signed [OUTW-1:0]  out
);
  // sum width = INW + clog2(WIN) to avoid overflow
  localparam SUMW = INW + $clog2(WIN);

  // circular buffer for window samples
  reg signed [INW-1:0] buffer [0:WIN-1];
  reg signed [SUMW-1:0] sum;
  reg [$clog2(WIN)-1:0] idx;
  integer i;

  always @(posedge clk) begin
    if (rst) begin
      sum <= 0;
      idx <= 0;
      out <= 0;
      for (i = 0; i < WIN; i = i + 1) buffer[i] <= 0;
    end else begin
      // accumulate: remove oldest, add newest
      sum <= sum - buffer[idx] + in;
      buffer[idx] <= in;
      idx <= idx + 1;

      // divide by WIN (power of two recommended) -> use shift
      out <= $signed(sum >>> $clog2(WIN));
    end
  end
endmodule
