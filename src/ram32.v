module RAM32 (
    input  wire CLK,
    input  wire [4:0] A,     // Address (32 words)
    input  wire [31:0] D,    // Data in
    input  wire WE,          // Write enable
    output wire [31:0] Q     // Data out
);
    // This is a hard macro from sky130 - leave empty (blackbox)
endmodule
