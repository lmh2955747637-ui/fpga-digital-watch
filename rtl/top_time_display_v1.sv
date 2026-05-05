`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       CLOCK_50,
    input  logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // =========================================================
  // Run control for restartable rate generators
  // Only the selected slow generator runs.
  // =========================================================
  logic run_1hz, run_25hz, run_1khz;

  assign run_1hz  = (SW == 2'b00);
  assign run_25hz = (SW == 2'b01);
  assign run_1khz = (SW == 2'b10);

  // =========================================================
  // Tick generation
  // =========================================================
  logic tick_1hz, tick_25hz, tick_1khz;
  logic tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_1hz (
      .clk (CLOCK_50),
      .run (run_1hz),
      .tick(tick_1hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_25hz (
      .clk (CLOCK_50),
      .run (run_25hz),
      .tick(tick_25hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_1khz (
      .clk (CLOCK_50),
      .run (run_1khz),
      .tick(tick_1khz)
  );

  // =========================================================
  // Tick selection
  // SW=11 means full speed: advance every clock cycle.
  // =========================================================
  always_comb begin
    unique case (SW)
      2'b00:   tick = tick_1hz;
      2'b01:   tick = tick_25hz;
      2'b10:   tick = tick_1khz;
      2'b11:   tick = 1'b1;
      default: tick = 1'b0;
    endcase
  end

  // =========================================================
  // Time counter
  // =========================================================
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  hms_counter u_time (
      .clk    (CLOCK_50),
      .enable (tick),
      .hours  (hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // =========================================================
  // Binary to BCD
  // binary_to_bcd expects a 7-bit input
  // =========================================================
  logic [3:0] h_tens, h_ones;
  logic [3:0] m_tens, m_ones;
  logic [3:0] s_tens, s_ones;

  binary_to_bcd u_bcd_hours (
      .bin ({2'b00, hours}),  // 5 -> 7 bits
      .tens(h_tens),
      .ones(h_ones)
  );

  binary_to_bcd u_bcd_minutes (
      .bin ({1'b0, minutes}),  // 6 -> 7 bits
      .tens(m_tens),
      .ones(m_ones)
  );

  binary_to_bcd u_bcd_seconds (
      .bin ({1'b0, seconds}),  // 6 -> 7 bits
      .tens(s_tens),
      .ones(s_ones)
  );

  // =========================================================
  // No blanking
  // =========================================================
  logic blank_h, blank_m, blank_s;

  assign blank_h = 1'b0;
  assign blank_m = 1'b0;
  assign blank_s = 1'b0;

  // =========================================================
  // Seven-segment display
  // =========================================================
  seven_segment u_HEX5 (
      .digit   (h_tens),
      .blank   (blank_h),
      .segments(HEX5)
  );

  seven_segment u_HEX4 (
      .digit   (h_ones),
      .blank   (blank_h),
      .segments(HEX4)
  );

  seven_segment u_HEX3 (
      .digit   (m_tens),
      .blank   (blank_m),
      .segments(HEX3)
  );

  seven_segment u_HEX2 (
      .digit   (m_ones),
      .blank   (blank_m),
      .segments(HEX2)
  );

  seven_segment u_HEX1 (
      .digit   (s_tens),
      .blank   (blank_s),
      .segments(HEX1)
  );

  seven_segment u_HEX0 (
      .digit   (s_ones),
      .blank   (blank_s),
      .segments(HEX0)
  );

endmodule
