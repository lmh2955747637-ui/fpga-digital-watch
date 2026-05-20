`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic       probe_running,
    output logic [2:0] probe_mode_enable,
`endif

    input logic       clk,
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

  // ----------------
  // Unused signals
  // ----------------

  logic unused;
  assign unused = button[2];

  // ----------------
  // Rising-edge detection
  // ----------------

  logic rise_start_stop;

  rising_edge_detector u_rise_start_stop (
      .clk   (clk),
      .sig_in(button[0]),
      .rise  (rise_start_stop)
  );

  // ----------------
  // Running control
  // ----------------

  logic running = 1'b0;

  logic timer_zero;
  logic total_nonzero;

  logic [2:0] mode_enable;

  always_ff @(posedge clk) begin
    if (timer_zero || (mode_enable != 3'b000)) begin
      running <= 1'b0;
    end else if (rise_start_stop && total_nonzero) begin
      running <= !running;
    end
  end

  // ----------------
  // Edit mode selector
  // ----------------

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk        (clk),
      .button     (button[3] && !running),
      .mode_enable(mode_enable)
  );

  // ----------------
  // PWM flashing
  // ----------------

  logic pwm_out;

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND * 4 / 10)
  ) u_pwm (
      .clk    (clk),
      .rst    (1'b0),
      .pwm_out(pwm_out)
  );

  // ----------------
  // 1 Hz tick generator
  // ----------------

  logic second_tick;
  logic count_tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_tick (
      .clk (clk),
      .run (running),
      .tick(second_tick)
  );

  assign count_tick = running && second_tick;

  // ----------------
  // Auto-repeat editing
  // ----------------

  logic inc_pulse;
  logic dec_pulse;

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_repeat (
      .clk   (clk),
      .button(button[1]),
      .pulse (inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_repeat (
      .clk   (clk),
      .button(button[0]),
      .pulse (dec_pulse)
  );

  // ----------------
  // Timer counters
  // ----------------

  logic [6:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic sec_borrow;
  logic min_borrow;
  logic unused_borrow;

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk       (clk),
      .clr       (1'b0),
      .tick      (count_tick),
      .edit_mode (mode_enable[0]),
      .inc       (mode_enable[0] && inc_pulse),
      .dec       (mode_enable[0] && dec_pulse),
      .count     (seconds),
      .borrow_out(sec_borrow)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk       (clk),
      .clr       (1'b0),
      .tick      (sec_borrow),
      .edit_mode (mode_enable[1]),
      .inc       (mode_enable[1] && inc_pulse),
      .dec       (mode_enable[1] && dec_pulse),
      .count     (minutes),
      .borrow_out(min_borrow)
  );

  editable_countdown #(
      .MAX  (23),
      .WIDTH(7)
  ) u_hours (
      .clk       (clk),
      .clr       (1'b0),
      .tick      (min_borrow),
      .edit_mode (mode_enable[2]),
      .inc       (mode_enable[2] && inc_pulse),
      .dec       (mode_enable[2] && dec_pulse),
      .count     (hours),
      .borrow_out(unused_borrow)
  );

  // ----------------
  // Timer state checks
  // ----------------

  assign timer_zero = (hours == 0) && (minutes == 0) && (seconds == 0);

  assign total_nonzero = !timer_zero;

  // ----------------
  // Display outputs
  // ----------------

  assign hours_disp = hours;
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Flash selected field
  assign blank_seconds = mode_enable[0] && pwm_out;
  assign blank_minutes = mode_enable[1] && pwm_out;
  assign blank_hours = mode_enable[2] && pwm_out;

  // LEDs
  assign led = sw;

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule
