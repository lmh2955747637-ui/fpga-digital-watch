`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  // Stores the previous value of sig_in
  logic prev_sig_in;

  // Update previous input value on each rising clock edge
  always_ff @(posedge clk) begin
    prev_sig_in <= sig_in;
  end

  // Assert rise when sig_in transitions from 0 to 1
  always_comb begin
    rise = sig_in & ~prev_sig_in;
  end

endmodule
