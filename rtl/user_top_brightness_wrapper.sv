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

  // PWM period = 1 ms
  localparam int PwmPeriod = CYCLES_PER_SECOND / 1000;

  // Counter width required for PWM period
  localparam int PwmWidth = $clog2(PwmPeriod);

  logic [PwmWidth-1:0] pwm_count;

  logic pwm_on;
  logic pwm_blank;

  logic app_blank_hours;
  logic app_blank_minutes;
  logic app_blank_seconds;


  // Original application instance
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


  // PWM counter
  mod_n_counter #(
      .N(PwmPeriod),
      .WIDTH(PwmWidth)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );


  // PWM brightness selection logic
  // verilator lint_off ALWAYSCOMB
  always @(*) begin
    case (sw[9:8])

      // 12.5% brightness
      2'b00: pwm_on = (pwm_count < PwmWidth'(PwmPeriod / 8));

      // 25% brightness
      2'b01: pwm_on = (pwm_count < PwmWidth'(PwmPeriod / 4));

      // 50% brightness
      2'b11: pwm_on = (pwm_count < PwmWidth'(PwmPeriod / 2));

      // 100% brightness
      2'b10: pwm_on = 1'b1;

      default: pwm_on = 1'b0;

    endcase

  end


  // Active-high PWM blanking signal
  assign pwm_blank = ~pwm_on;


  // Combine application blanking with PWM blanking
  assign blank_hours = app_blank_hours | pwm_blank;
  assign blank_minutes = app_blank_minutes | pwm_blank;
  assign blank_seconds = app_blank_seconds | pwm_blank;

endmodule

// Brightness wrapper for user_top.
//
// Parameters:
// CYCLES_PER_SECOND - System clock frequency.
//
// Ports:
// clk               - System clock.
// button            - Push-button inputs.
// sw                - Switch inputs.
// led               - LED outputs.
// hours_disp        - Seven-segment hours display.
// minutes_disp      - Seven-segment minutes display.
// seconds_disp      - Seven-segment seconds display.
// blank_hours       - Active-high blanking for hours display.
// blank_minutes     - Active-high blanking for minutes display.
// blank_seconds     - Active-high blanking for seconds display.
//
// Behaviour:
// - Instantiates user_top internally.
// - Passes all display outputs directly from user_top.
// - Intercepts blanking outputs from user_top.
// - Applies PWM-based brightness control.
// - Preserves application blanking behaviour.
// - Uses Grey code brightness selection on sw[9:8].
// - PWM period is 1 ms.
//
// Brightness Mapping:
// sw[9:8] = 00 -> 12.5% duty cycle
// sw[9:8] = 01 -> 25% duty cycle
// sw[9:8] = 11 -> 50% duty cycle
// sw[9:8] = 10 -> 100% duty cycle
