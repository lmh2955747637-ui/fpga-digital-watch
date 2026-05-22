`timescale 1ns / 1ps

module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles in one PWM period
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  // Number of bits required to count up to PERIOD_CYCLES-1
  localparam int CountWidth = $clog2(PERIOD_CYCLES);

  // Current position within the PWM period
  logic [CountWidth-1:0] count;

  // Counter repeatedly counts from 0 to PERIOD_CYCLES-1
  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(CountWidth)
  ) u_period_counter (
      .clk   (clk),
      .rst   (rst),
      .enable(1'b1), // Permanently enabled
      .count (count)
  );

  // Output high for the first DUTY_CYCLES counts
  // Output low for the remainder of the period
  always_comb begin
    pwm_out = ({1'b0, count} < (CountWidth + 1)'(DUTY_CYCLES));
  end

endmodule

// PWM signal generator.
//
// Generates a Pulse Width Modulation (PWM) waveform using a counter.
//
// Parameters:
//   PERIOD_CYCLES - Total number of clock cycles in one PWM period.
//   DUTY_CYCLES   - Number of clock cycles the output stays high
//                   during each PWM period.
//
// Ports:
//   clk     - System clock input.
//   rst     - Active-high reset input.
//   pwm_out - PWM output signal.
//
// Behaviour:
// - A counter repeatedly counts from 0 to PERIOD_CYCLES-1.
// - 'pwm_out' is high while count < DUTY_CYCLES.
// - 'pwm_out' is low for the remainder of the PWM period.
// - Duty cycle ratio = DUTY_CYCLES / PERIOD_CYCLES.
//
// Notes:
// - Counter width is automatically calculated using $clog2.
// - Width casting is used to avoid lint warnings.
// - Designed for FPGA-based PWM applications.
