`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  // Registered version of run (Moore FSM state)
  logic running = 1'b0;
  always_ff @(posedge clk) running <= run;

  // Internal signal
  logic tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general

      // Counter width
      localparam int CountWidth = $clog2(CYCLE_COUNT);

      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;

      // Instantiate mod-N counter
      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      // Control counter (use run for immediate response)
      assign rst_count    = ~run;
      assign enable_count = run;

      // Generate tick when count reaches N-1
      assign tick_qualifier =
                (count == CountWidth'(CYCLE_COUNT - 1));

      // Moore output
      assign tick = running && tick_qualifier;

    end else begin : g_special

      // CYCLE_COUNT = 1 case (Moore-compliant)
      assign tick = running;

    end
  endgenerate

endmodule
