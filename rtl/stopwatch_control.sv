`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst = 1'b0,
    output logic counter_enable = 1'b0,
    output logic lap_hold = 1'b0
);

  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;

  // counter_enable next-state logic
  assign next_counter_enable = (rise_start_stop && !rise_lap) ? ~counter_enable : counter_enable;

  // lap_hold next-state logic
  assign next_lap_hold =
      (rise_lap && !rise_start_stop && counter_enable)
      ? ~lap_hold :
      (rise_lap && !rise_start_stop && !counter_enable && lap_hold) // Unfreeze
      ? 1'b0 : lap_hold;

  // counter_rst next-state logic
  always_comb begin
    next_counter_rst = 1'b0;

    // Enter reset state only when stopped and live
    if (rise_lap && !rise_start_stop && !counter_enable && !lap_hold) begin
      next_counter_rst = 1'b1;
    end
  end

  // State registers
  always_ff @(posedge clk) begin
    counter_rst    <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold       <= next_lap_hold;
  end

endmodule

// Stopwatch control FSM.
//
// Ports:
// clk               - Clock input.
// rise_start_stop   - Single-cycle pulse for start/stop button.
// rise_lap          - Single-cycle pulse for lap/reset button.
// counter_rst       - Counter reset pulse output.
// counter_enable    - Enables stopwatch counting.
// lap_hold          - Freezes displayed value when high.
//
// Behaviour:
// - All outputs initialise to 0.
// - rise_start_stop toggles counter_enable.
// - rise_lap toggles lap_hold while running.
// - rise_lap unfreezes display while stopped and frozen.
// - rise_lap resets the counter while stopped and live.
// - Simultaneous button presses are ignored.
// - counter_rst is asserted for exactly one clock cycle.
//
// State Encoding:
// {counter_rst, counter_enable, lap_hold}
//
// States:
// 000 = STOP_LIVE
// 001 = STOP_FROZEN
// 010 = RUN_LIVE
// 011 = RUN_FROZEN
// 100 = RESET
