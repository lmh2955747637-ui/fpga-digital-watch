`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input  logic             clk,
    input  logic             hold,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] snapshot = '0;

  // Snapshot storage
  always_ff @(posedge clk) begin
    if (!hold) begin
      snapshot <= d;
    end
  end

  // Output selection logic
  always_comb begin
    if (hold) begin
      q = snapshot;
    end else begin
      q = d;
    end
  end

endmodule

// Snapshot multiplexer with transparent and hold behaviour.
//
// Parameters:
// WIDTH - Bit-width of the input and output signals.
//
// Ports:
// clk  - Clock input; snapshot updates on the rising edge.
// hold - Hold control:
//        0 = transparent mode (q follows d immediately)
//        1 = hold mode (q outputs the stored snapshot value)
// d    - Input signal (WIDTH bits).
// q    - Output signal (WIDTH bits).
//
// Behaviour:
// - Snapshot register initialises to 0.
// - When hold = 0:
//     * q follows d combinatorially.
//     * snapshot updates to d on each rising clock edge.
// - When hold = 1:
//     * q is frozen at the most recently stored snapshot value.
//     * snapshot no longer updates.
//
// Notes:
// - Uses always_ff for sequential snapshot storage.
// - Uses always_comb for output selection logic.
// - Snapshot storage is conditionally updated to preserve held values.
// - Initialisation avoids formal verification and linting issues.
