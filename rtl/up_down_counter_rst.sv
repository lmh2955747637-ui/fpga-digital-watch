`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = '0
);

  // Properly sized local parameters
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);

  logic [WIDTH-1:0] next_count;

  // Next-state logic
  always_comb begin
    if (up) begin
      // Increment
      if (count == Max) next_count = '0;
      else next_count = count + One;
    end else begin
      // Decrement
      if (count == '0) next_count = Max;
      else next_count = count - One;
    end
  end

  // State update (enable gated)
  always_ff @(posedge clk) begin
    if (rst) count <= '0;
    else if (enable) count <= next_count;
  end
endmodule

// Up-down counter with enable and wrap-around behavior.
//
// Parameters:
// MAX   - Maximum count value. Counter wraps to 0 when incrementing past MAX,
//         and wraps to MAX when decrementing below 0.
// WIDTH - Bit-width of the counter output.
//
// Ports:
// clk    - Clock input; state updates on the rising edge.
// enable - When low, the counter holds its current value.
//          When high, the counter updates on each clock edge.
// up     - Direction control:
//          1 = increment
//          0 = decrement
// count  - Current counter value (WIDTH bits).
// rst    - Active-high synchronous reset. When high, count resets to 0.
//
// Behaviour:
// - Counter initialises to 0.
// - When enable = 0: count does not change.
// - When enable = 1:
//     * If up = 1: count increments, wrapping MAX → 0.
//     * If up = 0: count decrements, wrapping 0 → MAX.
// - When rst = 1: count resets to 0 on the next rising clock edge.
//
// Notes:
// - Uses always_ff for sequential logic and always_comb for next-state logic.
// - All constants are width-cast to avoid lint warnings.
