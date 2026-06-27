module adc_if(
    input wire clk,
    input wire rst,
    input wire signed [15:0] sample_in,
    output reg signed [15:0] sample_out,
    output reg [31:0] sample_index
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
        sample_out <= 0;
        sample_index <= 0;
    end else begin
        sample_out <= sample_in;  // pass input directly
        sample_index <= sample_index + 1;
    end
  end
endmodule
