// ============================================================
// tb_top.v — Testbench for ECG processing pipeline
// ============================================================
`timescale 1ns/1ps
module tb_top;

  // Clock: 100 MHz
  reg clk = 0;
  always #5 clk = ~clk;

  // Reset
  reg rst;
  initial begin
    rst = 1;
    #100 rst = 0;
  end

  // Input sample
  reg signed [15:0] sample_in;

  // DUT outputs
  wire signed [15:0] filtered_out;
  wire signed [31:0] mwi_out;
  wire               r_peak;
  wire [15:0]        heart_rate;
  wire [31:0]        sample_index;

  // Instantiate top module
  top dut (
    .clk(clk),
    .rst(rst),
    .sample_in(sample_in),
    .filtered_out(filtered_out),
    .mwi_out(mwi_out),
    .r_peak(r_peak),
    .heart_rate(heart_rate),
    .sample_index_out(sample_index)
  );

  // ==========================================================
  // Simulation parameters
  // ==========================================================
  localparam integer FS = 250;           // Hz
  localparam integer SAMPLE_NS = 4_000_000_000 / FS; // ~4ms per sample = 4000 ns
  localparam integer PIPELINE_DELAY = 30; // few samples of latency

  // File handles
  integer infile, outfile;
  integer ret;
  integer sample_count = 0;

  initial begin
    // Open input file
    infile = $fopen("C:/modelsim_work_space/ECG_VLSI_PROJECT/data/ecg_samples.csv", "r");
    if (infile == 0) begin
      $display("ERROR: Failed to open input CSV!");
      $finish;
    end else begin
      $display("SUCCESS: Opened ECG input file");
    end

    // Open output file
    outfile = $fopen("C:/modelsim_work_space/ECG_VLSI_PROJECT/results/annotated_out.csv", "w");
    if (outfile == 0) begin
      $display("ERROR: Failed to open output CSV for writing!");
      $finish;
    end

    // Write CSV header
    $fwrite(outfile, "sample_index,sample_in,filtered_out,mwi_out,r_peak,heart_rate\n");

    // Feed samples
    while (!$feof(infile)) begin
      ret = $fscanf(infile, "%d\n", sample_in);
      if (ret == 1) begin
        sample_count = sample_count + 1;
        @(posedge clk);
        // Wait equivalent to sample period (4ms)
        #(SAMPLE_NS);

        // Write output data to CSV
        $fwrite(outfile, "%0d,%0d,%0d,%0d,%0d,%0d\n",
                sample_index, sample_in, filtered_out, mwi_out, r_peak, heart_rate);

        // ==========================================================
        // 👇 ADD THIS LINE — shows results in ModelSim Transcript
        // ==========================================================
        $display("Index=%0d | In=%0d | Filtered=%0d | MWI=%0d | Rpeak=%0d | HR=%0d",
                 sample_index, sample_in, filtered_out, mwi_out, r_peak, heart_rate);
        // ==========================================================

        if (sample_count % 1000 == 0)
          $display("Progress: %0d samples processed...", sample_count);
      end
    end

    $display("Simulation complete. %0d samples processed.", sample_count);
    $fclose(infile);
    $fclose(outfile);
    #10000 $finish;
  end

endmodule
