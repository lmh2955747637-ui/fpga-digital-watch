`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input  logic             clk,
    input  logic             clr,
    input  logic             tick,
    input  logic             edit_mode,
    input  logic             inc,
    input  logic             dec,
    output logic [WIDTH-1:0] count,
    output logic             borrow_out
);

  logic enable;
  logic up;

  // Valid edit events only occur when inc and dec
  // are not pressed at the same time.
  assign enable = (!edit_mode && tick) || (edit_mode && inc && !dec) || (edit_mode && dec && !inc);

  // 1 = increment, 0 = decrement
  assign up = edit_mode && inc && !dec;

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk   (clk),
      .rst   (clr),
      .enable(enable),
      .up    (up),
      .count (count)
  );

  // Borrow only during normal countdown mode
  assign borrow_out = !clr && !edit_mode && tick && (count == '0);

endmodule

// Editable countdown counter with enable,
// wrap-around and borrow output behaviour.
//
// Parameters:
// MAX   - Maximum counter value. Counter wraps to MAX
//         when decrementing below 0.
// WIDTH - Bit-width of the counter output.
//
// Ports:
// clk        - Clock input.
// clr        - Active-high synchronous clear.
// tick       - Countdown tick input.
// edit_mode  - Enables manual editing mode.
// inc        - Increment pulse during edit mode.
// dec        - Decrement pulse during edit mode.
// count      - Current counter value.
// borrow_out - Borrow pulse generated when
//              decrementing below 0.
//
// Behaviour:
// - Counter initialises to 0.
// - When clr = 1: count resets to 0 on the
//   next rising edge.
// - When edit_mode = 0:
//     * count decrements on each tick pulse.
//     * count wraps from 0 to MAX.
// - When edit_mode = 1:
//     * inc increments the counter.
//     * dec decrements the counter.
// - borrow_out is asserted only when the
//   counter attempts to decrement below 0
//   during countdown mode.
//
// Notes:
// - Uses up_down_counter_rst as the only
//   directly instantiated dependency.
// - borrow_out is combinational.
