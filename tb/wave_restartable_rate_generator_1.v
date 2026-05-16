`timescale 1ns / 1ps

module wave_restartable_rate_generator_1;

  reg  clk = 0;
  reg  run = 0;
  wire tick;

  // DUT with CYCLE_COUNT = 1
  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) dut (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  // 10 ns clock period
  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_restartable_rate_generator_1.vcd");
    $dumpvars(0, wave_restartable_rate_generator_1);

    // Initially disabled
    run = 0;
    #20;

    // Enable
    // tick should become active continuously
    run = 1;
    #40;

    // Disable
    // tick should immediately stop
    run = 0;
    #20;

    // Re-enable
    run = 1;
    #30;

    // Stop again
    run = 0;
    #20;

    $finish;
  end

endmodule
