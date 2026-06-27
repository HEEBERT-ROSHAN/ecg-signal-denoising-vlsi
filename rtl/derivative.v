// derivative.v
`timescale 1ns/1ps
module derivative #(
  parameter WIDTH = 16
)(
  input wire clk,
  input wire rst,
  input wire signed [WIDTH-1:0] in,
  output reg signed [WIDTH-1:0] out
);
  reg signed [WIDTH-1:0] prev;
  always @(posedge clk) begin
    if (rst) begin
      prev <= 0;
      out <= 0;
    end else begin
      out <= in - prev;
      prev <= in;
    end
  end
endmodule

