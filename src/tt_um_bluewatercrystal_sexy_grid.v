module tt_um_bluewatercrystal_cpu (  // your exact module name
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Bidirectional pins (bits 7:0 used as input)
    output wire [7:0] uio_out,  // IOs: Bidirectional pins (bits 7:0 used as output)
    output wire [7:0] uio_oe,   // IOs: Bidirectional enables (active high: 0=input, 1=output)
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // Example: 6 cores like your first ref image
    core core0 (.clk(clk), .rst_n(rst_n), .dummy_out(uo_out[7:0]));  // reuse one output for demo
    core core1 (.clk(clk), .rst_n(rst_n));
    core core2 (.clk(clk), .rst_n(rst_n));
    core core3 (.clk(clk), .rst_n(rst_n));
    core core4 (.clk(clk), .rst_n(rst_n));
    core core5 (.clk(clk), .rst_n(rst_n));

    // Central shared L3 cache (big dense block)
    shared_l3 l3_cache (.clk(clk), .rst_n(rst_n));

    // Placeholder for memory controller (bottom) - can add more logic/RAM later
    // For now, just some filler regs to make a block
    reg [255:0] mem_ctrl_filler;
    always @(posedge clk) mem_ctrl_filler <= {mem_ctrl_filler[254:0], rst_n};

    // Assign unused outputs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
