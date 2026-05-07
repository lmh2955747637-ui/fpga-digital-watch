`timescale 1ns / 1ps

module button_auto_repeat #(

    // Number of clock cycles before first repeat pulse
    parameter int HOLD_CYCLES = 50_000_000,

    // Number of clock cycles between repeated pulses
    // Must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000

) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  // Immediate pulse generated when button is first pressed
  logic rise;

  // Asserted once button has been held long enough
  logic held;

  // Periodic pulse train during long button hold
  logic pulse_train;

  // Generate immediate pulse on rising edge of button
  rising_edge_detector u_rise_detector (
      .clk   (clk),
      .sig_in(button),
      .rise  (rise)
  );

  // Detect when button has been held long enough
  // Threshold adjusted so first repeat occurs exactly
  // on the HOLD_CYCLES-th clock edge
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_hold_detect (
      .clk   (clk),
      .button(button),
      .held  (held)
  );

  // Generate periodic repeat pulses while button remains held
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate_generator (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

  // Output immediate pulse or repeated pulse train
  // Gating with button prevents spurious pulses after release
  assign pulse = rise | (button & pulse_train);

endmodule
