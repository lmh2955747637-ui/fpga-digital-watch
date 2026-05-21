`timescale 1ns / 1ps

module user_top_brightness_wrapper #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
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

  // ----------------------------------------------------------------
  // Internal signals from user_top
  // ----------------------------------------------------------------

  logic        app_blank_hours;
  logic        app_blank_minutes;
  logic        app_blank_seconds;

  // ----------------------------------------------------------------
  // PWM signals
  // ----------------------------------------------------------------

  logic [15:0] pwm_count;
  logic        pwm_on;
  logic        pwm_blank;

  // ----------------------------------------------------------------
  // Instantiate original app
  // ----------------------------------------------------------------

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk(clk),
      .button(button),
      .sw(sw),

      .led(led),

      .hours_disp  (hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),

      .blank_hours  (app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  // ----------------------------------------------------------------
  // PWM counter
  // 1 ms period at 50 MHz
  // 50,000 cycles
  // ----------------------------------------------------------------

  mod_n_counter #(
      .N(50000),
      .WIDTH(16)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  // ----------------------------------------------------------------
  // Brightness control
  //
  // sw[9:8]
  // 00 -> 12.5%
  // 01 -> 25%
  // 11 -> 50%
  // 10 -> 100%
  // ----------------------------------------------------------------

  always_comb begin
    unique case (sw[9:8])

      // 12.5%
      2'b00: pwm_on = (pwm_count < 16'd6250);

      // 25%
      2'b01: pwm_on = (pwm_count < 16'd12500);

      // 50%
      2'b11: pwm_on = (pwm_count < 16'd25000);

      // 100%
      2'b10: pwm_on = 1'b1;

      default: pwm_on = 1'b0;

    endcase
  end

  // Active-high blanking
  assign pwm_blank = ~pwm_on;

  // ----------------------------------------------------------------
  // Combine app blanking with PWM blanking
  // ----------------------------------------------------------------

  assign blank_hours = app_blank_hours | pwm_blank;
  assign blank_minutes = app_blank_minutes | pwm_blank;
  assign blank_seconds = app_blank_seconds | pwm_blank;

endmodule
