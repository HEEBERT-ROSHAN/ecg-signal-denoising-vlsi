// hp_filter.v
`timescale 1ns/1ps
module hp_filter #(
  parameter WIDTH = 16,
  parameter N = 128   // moving average window (power of two)
)(
  input wire clk,
  input wire rst,
  input wire signed [WIDTH-1:0] in,
  output reg signed [WIDTH-1:0] out
);
  localparam SUMW = WIDTH + $clog2(N);
  reg signed [WIDTH-1:0] buffer [0:N-1];
  reg signed [SUMW-1:0] sum;
  integer i;
  reg [$clog2(N)-1:0] idx;

  always @(posedge clk) begin
    if (rst) begin
      sum <= 0;
      idx <= 0;
      out <= 0;
      for (i=0; i<N; i=i+1) buffer[i] <= 0;
    end else begin
      sum <= sum - buffer[idx] + in;
      buffer[idx] <= in;
      idx <= idx + 1;
      // result = in - average(sum)
      // average = sum / N -> N is power-of-two so /N becomes shift
      out <= in - $signed(sum >>> $clog2(N));
    end
  end
endmodule

