// squaring.v
`timescale 1ns/1ps
module squaring #(
  parameter INW = 16,
  parameter OUTW = 32
)(
  input wire clk,
  input wire rst,
  input wire signed [INW-1:0] in,
  output reg [OUTW-1:0] out
);
  reg signed [INW-1:0] v;
  reg signed [2*INW-1:0] prod;
  always @(posedge clk) begin
    if (rst) begin
      v <= 0;
      prod <= 0;
      out <= 0;
    end else begin
      v <= in;
      prod <= v * v; // signed multiply; square is positive
      out <= prod[OUTW-1:0]; // truncate/fit into OUTW
    end
  end
endmodule

