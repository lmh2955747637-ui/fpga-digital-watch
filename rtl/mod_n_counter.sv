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

// Mod-N synchronous counter with enable and reset.
//
// Parameters:
// N     - Counter modulus. Counter counts from 0 to N-1.
// WIDTH - Bit width of the counter output.
//
// Ports:
// clk              - Clock input; counter updates on rising edge.
// rst              - Active-high synchronous reset.
// enable           - When high, counter increments each clock cycle.
// count[WIDTH-1:0] - Current counter value.
//
// Behaviour:
// - Counter starts at 0.
// - When rst = 1, count resets to 0.
// - When enable = 1, count increments on each rising clock edge.
// - When count reaches N-1, it wraps around to 0.
// - When enable = 0, the counter holds its current value.
//
// Notes:
// - Uses always_comb for next-state logic.
// - Uses always_ff for sequential state updates.
// - MAX is width-cast to avoid width-mismatch warnings.
