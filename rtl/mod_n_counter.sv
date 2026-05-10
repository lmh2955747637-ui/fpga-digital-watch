`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N     = 4,  // Modulus (0 to N-1)
    parameter int WIDTH = 2   // Bit width
) (
    input  logic             clk,        // Clock
    input  logic             rst,        // Reset (active high)
    input  logic             enable,     // Enable counting
    output logic [WIDTH-1:0] count = '0  // Current count
);
  localparam logic [WIDTH-1:0] MAX = WIDTH'(N - 1);
  logic [WIDTH-1:0] next_count;  // Next state


  // Compute next count value
  always_comb begin
    if (count == MAX) next_count = '0;  // Wrap to 0
    else next_count = count + 1;  // Increment
  end

  // Update register on clock edge
  always_ff @(posedge clk) begin
    if (rst) count <= '0;  // Reset to 0
    else if (enable) count <= next_count;  // Update when enabled
  end

endmodule

// Seven-segment display decoder for hexadecimal digits.
//
// Parameters:
// ACTIVE_LOW - 1: active-low outputs, 0: active-high outputs.
//
// Ports:
// digit   [3:0] - Input hex digit (0x0 to 0xF).
// blank          - When high, all segments off.
// segments[6:0] - Output segments [g,f,e,d,c,b,a].
