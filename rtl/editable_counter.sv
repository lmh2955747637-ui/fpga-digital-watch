`timescale 1ns / 1ps

module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input  logic             clk,
    input  logic             tick,       // Count increments on tick when edit_mode is low
    input  logic             edit_mode,
    input  logic             inc,        // Count increments by one when edit_mode is high
    input  logic             dec,        // Count decrements by one when edit_mode is high
    output logic [WIDTH-1:0] count
);

  logic enable;
  logic up;

  // Up/down counter instance
  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk   (clk),
      .enable(enable),
      .up    (up),
      .count (count)
  );

  // Event generation
  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  // Count direction
  // Increment during normal tick operation or increment edit event
  // Decrement during decrement edit event
  assign up = inc_event || tick_event;

  // Enable counter whenever any valid event occurs
  assign enable = inc_event || dec_event || tick_event;

endmodule
