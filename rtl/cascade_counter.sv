`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,

    output logic [W2-1:0] count2 = W2'(0),
    output logic [W1-1:0] count1 = W1'(0),
    output logic [W0-1:0] count0 = W0'(0)
);

  always_ff @(posedge clk) begin
    if (rst) begin
      count0 <= '0;
      count1 <= '0;
      count2 <= '0;
    end else if (enable) begin

      // count0
      if (count0 == W0'(N0 - 1)) begin
        count0 <= '0;

        // count1
        if (count1 == W1'(N1 - 1)) begin
          count1 <= '0;

          // count2
          if (count2 == W2'(N2 - 1)) count2 <= '0;
          else count2 <= count2 + W2'(1);

        end else begin
          count1 <= count1 + W1'(1);
        end

      end else begin
        count0 <= count0 + W0'(1);
      end
    end
  end

endmodule

// Cascaded multi-stage counter with enable and reset.
//
// Parameters:
// N2 - Maximum count value for count2 stage.
// N1 - Maximum count value for count1 stage.
// N0 - Maximum count value for count0 stage.

// W2 - Bit width of count2 output.
// W1 - Bit width of count1 output.
// W0 - Bit width of count0 output.
//
// Ports:
// clk    - Clock input; all updates occur on rising edges.
// rst    - Active-high synchronous reset.
// enable - When high, the counter updates; when low, values are held.
//
// count2 - Most significant counter stage.
// count1 - Middle counter stage.
// count0 - Least significant counter stage.
//
// Behaviour:
// - When rst = 1, all outputs are reset to 0 on the next rising clock edge.
// - When enable = 1, count0 increments on each rising clock edge.
// - When count0 reaches N0-1, it rolls over to 0 and increments count1.
// - When count1 reaches N1-1, it rolls over to 0 and increments count2.
// - When count2 reaches N2-1, it rolls over to 0.
// - The counter stages are cascaded using rollover conditions between stages.
