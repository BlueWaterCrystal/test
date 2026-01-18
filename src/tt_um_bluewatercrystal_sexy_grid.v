// tt_um_bluewatercrystal_sexy_grid.v
// Full top-level module for your 64-core chiplet grid design

`default_nettype none

module tt_um_bluewatercrystal_sexy_grid (
    input  wire [7:0] ui_in,    // Seed bits (for potential future use)
    output wire [7:0] uo_out,   // Mix result (simple demo output)
    input  wire [7:0] uio_in,   // Unused bidirectional inputs
    output wire [7:0] uio_out,  // Unused bidirectional outputs
    output wire [7:0] uio_oe,   // Bidirectional enable (0 = input, 1 = output)
    input  wire ena,            // Enable (active high)
    input  wire clk,            // Clock
    input  wire rst_n           // Reset (active low)
);

    // Simple demo output: XOR-reduction of inputs + clock/ena for visibility
    assign uo_out = ui_in ^ {ena, clk, rst_n, 5'b0};

    // Unused bidirectional pins
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // 64 RAM32 instances (DFFRAM hard macros) for dense chiplet "cores"
    // Each RAM32 appears as a regular dense rectangle in the die shot
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : chiplet
            RAM32 ram_inst (
                .CLK(clk),
                .A(5'd0),     // Dummy address (read-only for visuals)
                .D(32'd0),    // Dummy data in
                .WE(1'b0),    // No writes
                .Q()          // Outputs left open (common for visual/art tiles)
            );
        end
    endgenerate

    // Optional soft logic filler (uncomment if you want striped stdcell areas around the RAMs)
    /*
    genvar j;
    generate
        for (j = 0; j < 64; j = j + 1) begin : filler_logic
            reg [31:0] counter;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) counter <= {ui_in, 24'(j)};
                else counter <= counter + 32'd1;
            end
        end
    endgenerate
    */

endmodule

`default_nettype wire
