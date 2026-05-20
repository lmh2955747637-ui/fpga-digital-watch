`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  logic rise_start_stop;
  logic rise_lap;

  logic counter_rst;
  logic counter_enable;
  logic lap_hold;

  logic [6:0] live_minutes;
  logic [5:0] live_seconds;
  logic [6:0] live_centiseconds;

  logic [6:0] display_minutes;
  logic [5:0] display_seconds;
  logic [6:0] display_centiseconds;

  logic unused;

  assign unused = &{button[3:2], sw};

  // LEDs mirror switches
  assign led = sw;

  // All displays enabled
  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

  // Rising-edge detector for start/stop button
  rising_edge_detector u_start_stop_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  // Rising-edge detector for lap/reset button
  rising_edge_detector u_lap_edge (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  // Stopwatch control FSM
  stopwatch_control u_stopwatch_control (
      .clk(clk),

      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),

      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  // Stopwatch counter
  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch_counter (
      .clk(clk),

      .rst(counter_rst),
      .enable(counter_enable),

      .minutes(live_minutes),
      .seconds(live_seconds),
      .centiseconds(live_centiseconds)
  );

  // Snapshot mux for minutes
  snapshot_mux #(
      .WIDTH(7)
  ) u_minutes_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(live_minutes),
      .q(display_minutes)
  );

  // Snapshot mux for seconds
  snapshot_mux #(
      .WIDTH(6)
  ) u_seconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(live_seconds),
      .q(display_seconds)
  );

  // Snapshot mux for centiseconds
  snapshot_mux #(
      .WIDTH(7)
  ) u_centiseconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(live_centiseconds),
      .q(display_centiseconds)
  );

  // Display outputs
  assign hours_disp   = display_minutes;
  assign minutes_disp = {1'b0, display_seconds};
  assign seconds_disp = display_centiseconds;

endmodule

// Stopwatch integration top-level module.
//
// Parameters:
// CYCLES_PER_SECOND - Input clock frequency in Hz.
//
// Ports:
// clk            - System clock.
// button[0]      - Start/stop button.
// button[1]      - Lap/reset button.
// sw             - Switch inputs.
// led            - LED outputs.
// hours_disp     - Minutes display.
// minutes_disp   - Seconds display.
// seconds_disp   - Centiseconds display.
// blank_hours    - Hours display blanking control.
// blank_minutes  - Minutes display blanking control.
// blank_seconds  - Seconds display blanking control.
//
// Behaviour:
// - Uses rising-edge detectors for button presses.
// - stopwatch_control implements the stopwatch FSM.
// - stopwatch_counter generates live stopwatch time.
// - snapshot_mux freezes displayed values during lap mode.
// - Stopwatch continues running internally while display is frozen.
// - LEDs mirror switch values.
