`timescale 1ns / 1ps

module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic       clk,
    input  logic       button,
    output logic [2:0] mode_enable
);

  logic long_press;

  // Detect long button press and generate a pulse
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  logic press;

  // Detect the moment the button is pressed
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  logic armed;
  logic disarm;

  // Track whether the system is currently in edit mode
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );

  logic       reset_counter;
  logic       enable_counter;
  logic [1:0] count;

  // Wrap around counter when count reaches 2
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  // Enable counter only when edit mode is active and button is pressed
  assign enable_counter = armed && press;

  // Keep counter reset whenever edit mode is inactive
  assign reset_counter = !armed;

  // Exit edit mode when count is 2 and button is pressed again
  assign disarm = armed && press && (count == 2'd2);

  // Generate one-hot edit mode output
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
