// peak_detector.v
`timescale 1ns/1ps
module peak_detector #(
  parameter INW = 32,
  parameter FS = 250,           // sampling freq in Hz (set to your ECG sample rate)
  parameter REF_MS = 200,       // refractory window in milliseconds
  parameter INIT_SPKI = 1000,   // initial signal peak estimate
  parameter INIT_NPKI = 100     // initial noise peak estimate
)(
  input  wire                  clk,
  input  wire                  rst,
  input  wire signed [INW-1:0] in,         // mwi output (signed)
  input  wire       [31:0]     sample_index, // absolute sample index from ADC
  output reg                   r_peak,
  output reg signed [INW-1:0]  peak_value
);
  // local max detection over 3-sample window
  reg signed [INW-1:0] v0, v1, v2;

  // adaptive threshold variables (signed)
  reg signed [INW-1:0] SPKI; // signal peak estimate
  reg signed [INW-1:0] NPKI; // noise peak estimate
  reg signed [INW-1:0] THRESH;

  // refractory in samples
  localparam integer REF_SAMPLES = (FS * REF_MS) / 1000;

  reg [31:0] last_peak_sample;

  initial begin
    r_peak = 0;
    v0 = 0; v1 = 0; v2 = 0;
    SPKI = INIT_SPKI;
    NPKI = INIT_NPKI;
    THRESH = INIT_NPKI + ((INIT_SPKI - INIT_NPKI) >>> 2);
    last_peak_sample = 32'd0;
  end

  always @(posedge clk) begin
    if (rst) begin
      v0 <= 0; v1 <= 0; v2 <= 0;
      SPKI <= INIT_SPKI;
      NPKI <= INIT_NPKI;
      THRESH <= INIT_NPKI + ((INIT_SPKI - INIT_NPKI) >>> 2);
      last_peak_sample <= 32'd0;
      r_peak <= 1'b0;
      peak_value <= 0;
    end else begin
      r_peak <= 1'b0; // default low
      v2 <= v1;
      v1 <= v0;
      v0 <= in;

      // detect local maximum at v1 (middle sample)
      if ((v1 > v2) && (v1 > v0)) begin
        // ensure refractory time passed
        if ((sample_index - last_peak_sample) > REF_SAMPLES) begin
          if (v1 > THRESH) begin
            // detected signal peak
            last_peak_sample <= sample_index;
            r_peak <= 1'b1;
            peak_value <= v1;
            // update SPKI = 0.875*SPKI + 0.125*v1  (approx)
            SPKI <= ((SPKI * 7) + v1) >>> 3;
          end else begin
            // update noise peak NPKI = 0.875*NPKI + 0.125*v1
            NPKI <= ((NPKI * 7) + v1) >>> 3;
          end
          // update threshold = NPKI + 0.25*(SPKI - NPKI)
          THRESH <= NPKI + ((SPKI - NPKI) >>> 2);
        end
      end
    end
  end
endmodule
