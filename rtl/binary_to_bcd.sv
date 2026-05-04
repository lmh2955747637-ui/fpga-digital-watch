`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   // binary input, 0-99
    output logic [3:0] tens,  // decimal tens digit (BCD)
    output logic [3:0] ones   // decimal ones digit (BCD)
);

  // Tens digit: bin / 10 (cast to 4 bits)
  assign tens = 4'(bin / 7'd10);

  // Ones digit: remainder of division by 10
  assign ones = 4'(bin % 7'd10);
endmodule

// Binary to BCD converter (0–99).
//
// Converts a 7-bit binary input into two decimal digits using
// Binary-Coded Decimal (BCD) format.
//
// Parameters:
//   None
//
// Ports:
//   bin  [6:0] - Binary input value (0–99).
//   tens [3:0] - BCD tens digit (0–9).
//   ones [3:0] - BCD ones digit (0–9).
//
// Behaviour:
// - 'bin' is a standard binary number.
// - 'tens' = bin / 10 (most significant decimal digit).
// - 'ones' = bin % 10 (least significant decimal digit).
// - Each output is a 4-bit BCD digit (0000–1001).
//
// Notes:
// - Width casting is used to avoid lint warnings.
// - Designed for driving decimal displays (e.g. seven-segment).
