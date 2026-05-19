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
