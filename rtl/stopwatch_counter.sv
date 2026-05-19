`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,    // Takes priority over enable
    input logic enable,

    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

  // Number of clock cycles per centisecond
  localparam int CyclesPerCentisecond = CYCLES_PER_SECOND / 100;

  // 100 Hz tick signal
  logic centisecond_tick;

  // Counter enable signal
  logic counter_enable;

  // Generate one tick per centisecond.
  // The generator restarts whenever
  // enable goes low or rst goes high.
  restartable_rate_generator #(
      .CYCLE_COUNT(CyclesPerCentisecond)
  ) u_centisecond_rate (
      .clk (clk),
      .run (enable && !rst),
      .tick(centisecond_tick)
  );

  // Counter increments only when
  // enabled and a centisecond tick occurs.
  assign counter_enable = enable && centisecond_tick;

  // Cascaded stopwatch counter:
  // count0 = centiseconds (0-99)
  // count1 = seconds      (0-59)
  // count2 = minutes      (0-99)
  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),

      .W2(7),
      .W1(6),
      .W0(7)
  ) u_stopwatch_counter (
      .clk   (clk),
      .rst   (rst),
      .enable(counter_enable),

      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

endmodule


// Stopwatch counter with centisecond precision.
//
// Parameters:
// CYCLES_PER_SECOND - Input clock frequency in Hz.
//
// Ports:
// clk           - Clock input.
// rst           - Active-high synchronous reset.
// enable        - Enables stopwatch counting.
// minutes       - Minute count (0-99).
// seconds       - Second count (0-59).
// centiseconds  - Centisecond count (0-99).
//
// Behaviour:
// - Counts in centiseconds, seconds and minutes.
// - Uses restartable_rate_generator for 100 Hz timing.
// - Uses cascade_counter for cascaded counting.
// - First increment occurs one centisecond
//   after enable goes high.
