`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // =========================================================
  // Tick generation (slow clocks)
  // =========================================================
  logic tick_1hz, tick_25hz, tick_1khz;

  logic run = 1'b1;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_1hz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_25hz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_25hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_1khz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1khz)
  );

  // =========================================================
  // Tick selection (FIXED)
  // =========================================================
  logic tick, tick_next;

  always_comb begin
    case (SW)
      2'b00:   tick_next = tick_1hz;
      2'b01:   tick_next = tick_25hz;
      2'b10:   tick_next = tick_1khz;
      2'b11:   tick_next = ~CLOCK_50;  // ✅ 关键修复（错开时钟）
      default: tick_next = 1'b0;
    endcase
  end

  // ✅ 同步 tick（防 glitch）
  always_ff @(posedge CLOCK_50) tick <= tick_next;

  // =========================================================
  // Time counter
  // =========================================================
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  hms_counter u_time (
      .clk(CLOCK_50),
      .enable(tick),  // ✅ 必须用 enable
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // =========================================================
  // BCD conversion (zero extend!)
  // =========================================================
  logic [3:0] h_tens, h_ones;
  logic [3:0] m_tens, m_ones;
  logic [3:0] s_tens, s_ones;

  binary_to_bcd u_bcd_hours (
      .bin ({2'b0, hours}),
      .tens(h_tens),
      .ones(h_ones)
  );

  binary_to_bcd u_bcd_minutes (
      .bin ({1'b0, minutes}),
      .tens(m_tens),
      .ones(m_ones)
  );

  binary_to_bcd u_bcd_seconds (
      .bin ({1'b0, seconds}),
      .tens(s_tens),
      .ones(s_ones)
  );

  // =========================================================
  // Prevent X propagation (critical for cocotb)
  // =========================================================
  logic blank_h, blank_m, blank_s;

  assign blank_h = $isunknown(h_tens) || $isunknown(h_ones);
  assign blank_m = $isunknown(m_tens) || $isunknown(m_ones);
  assign blank_s = $isunknown(s_tens) || $isunknown(s_ones);

  // =========================================================
  // Seven segment display
  // =========================================================
  seven_segment u_HEX5 (
      .digit(h_tens),
      .blank(blank_h),
      .segments(HEX5)
  );
  seven_segment u_HEX4 (
      .digit(h_ones),
      .blank(blank_h),
      .segments(HEX4)
  );

  seven_segment u_HEX3 (
      .digit(m_tens),
      .blank(blank_m),
      .segments(HEX3)
  );
  seven_segment u_HEX2 (
      .digit(m_ones),
      .blank(blank_m),
      .segments(HEX2)
  );

  seven_segment u_HEX1 (
      .digit(s_tens),
      .blank(blank_s),
      .segments(HEX1)
  );
  seven_segment u_HEX0 (
      .digit(s_ones),
      .blank(blank_s),
      .segments(HEX0)
  );

endmodule
