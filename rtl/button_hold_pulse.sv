`timescale 1ns / 1ps

module button_hold_pulse #(

    // Number of consecutive clock cycles button must remain high
    parameter int HOLD_CYCLES = 50_000_000

) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  // Asserted once button has been held long enough
  logic held;

  // Detect long button hold
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk   (clk),
      .button(button),
      .held  (held)
  );

  // Generate a one-cycle pulse on rising edge of held
  rising_edge_detector u_detector (
      .clk   (clk),
      .sig_in(held),
      .rise  (pulse)
  );

endmodule
