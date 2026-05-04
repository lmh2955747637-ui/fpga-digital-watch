`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,
    parameter int N_MINUTES = 60,
    parameter int N_SECONDS = 60,

    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);

  // Max values (N-1)
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);

  // Rollover signals
  logic second_rollover;
  logic minute_rollover;

  // Detect rollovers
  assign second_rollover = (seconds == MaxSeconds) && enable;
  assign minute_rollover = (minutes == MaxMinutes) && second_rollover;

  // Seconds counter (always counts when enabled)
  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );

  // Minutes counter (only increments when seconds rolls over)
  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),
      .up(1'b1),
      .count(minutes)
  );

  // Hours counter (only increments when minutes rolls over)
  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),
      .up(1'b1),
      .count(hours)
  );

endmodule

// Cascaded hour-minute-second counter with enable.
//
// Parameters:
// N_HOURS   - Number of hours (default 24).
// N_MINUTES - Number of minutes (default 60).
// N_SECONDS - Number of seconds (default 60).
// W_HOURS   - Bit width of hours output.
// W_MINUTES - Bit width of minutes output.
// W_SECONDS - Bit width of seconds output.
//
// Ports:
// clk     - Clock input; all updates occur on rising edges.
// enable  - When high, the counter updates; when low, values are held.
// hours   - Current hour value (0 to N_HOURS-1).
// minutes - Current minute value (0 to N_MINUTES-1).
// seconds - Current second value (0 to N_SECONDS-1).
//
// Behaviour:
// - Seconds increment on each rising clock edge when enable = 1.
// - When seconds reaches N_SECONDS-1, it rolls over to 0 and increments minutes.
// - When minutes reaches N_MINUTES-1, it rolls over to 0 and increments hours.
// - When hours reaches N_HOURS-1, it rolls over to 0.
// - The counters are cascaded using rollover signals between stages.
