module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);

  // Initialize armed state to low
  initial armed = 1'b0;

  // Update armed state on rising clock edge
  always_ff @(posedge clk) begin

    // Clear armed state when disarm is asserted
    if (disarm) armed <= 1'b0;

    // Set armed state when arm is asserted
    else if (arm) armed <= 1'b1;
  end

endmodule
