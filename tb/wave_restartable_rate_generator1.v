`timescale 1ns / 1ps

module wave_restartable_rate_generator1;

  logic clk;
  logic run;
  logic tick;

  // DUT with CYCLE_COUNT = 1
  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) dut (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  // Clock: 10ns period
  always #5 clk = ~clk;

  initial begin
    // Dump waveform
    $dumpfile("wave_restartable_rate_generator1.vcd");
    $dumpvars(0, wave_restartable_rate_generator1);

    clk = 0;
    run = 0;

    // Display signals
    $display("Time\tclk\trun\ttick");
    $monitor("%0t\t%b\t%b\t%b", $time, clk, run, tick);

    // Test sequence
    #10 run = 1;
    #20 run = 0;
    #10 run = 1;
    #20 run = 0;

    #20 $finish;
  end

endmodule
