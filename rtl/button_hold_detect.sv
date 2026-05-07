`timescale 1ns / 1ps

module button_hold_detect #(

    // Number of consecutive clock cycles button must remain high
    parameter int HOLD_CYCLES = 50_000_000

) (
    input  logic clk,
    input  logic button,
    output logic held
);

  // Counter reaches this value when hold detected
  localparam int CountMax = HOLD_CYCLES;

  // Number of bits required to represent CountMax
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;

  // Counter value represents the FSM state
  logic [CountWidth-1:0] count;

  // Counter counts consecutive high button samples
  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk   (clk),
      .rst   (count_rst),
      .enable(count_enable),
      .count (count)
  );

  always_comb begin

    // Reset counter when button is released
    count_rst = ~button;

    // Continue counting until hold threshold reached
    count_enable = button & (count != CountWidth'(CountMax));

    // Assert held once maximum count reached
    held = (count == CountWidth'(CountMax));

  end

endmodule
