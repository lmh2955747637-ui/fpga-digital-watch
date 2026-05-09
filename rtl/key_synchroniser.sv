`timescale 1ns / 1ps

module key_synchroniser (
    input  logic       clk,
    input  logic [3:0] key_n,    // active-low, asynchronous
    output logic [3:0] key_sync  // active-high, synchronised
);

  logic [3:0] sync_ff1 = 4'b0000;
  logic [3:0] sync_ff2 = 4'b0000;

  // First synchroniser stage
  always_ff @(posedge clk) begin
    sync_ff1 <= ~key_n;
  end

  // Second synchroniser stage
  always_ff @(posedge clk) begin
    sync_ff2 <= sync_ff1;
  end

  assign key_sync = sync_ff2;

endmodule
