// tt_um_bluewatercrystal_sexy_grid.v
// Updated for classic CPU die shot mimic: 6 performance "cores" surrounding a large central shared L3 cache
// Plus memory controller (bottom horizontal block) and uncore/I/O (top horizontal block)
// All using RAM32 macros for dense blocks + soft logic for striped datapath look in cores

`default_nettype none

module tt_um_bluewatercrystal_sexy_grid (
    input  wire [7:0] ui_in,    // Seed bits
    output wire [7:0] uo_out,   // Simple demo output
    input  wire [7:0] uio_in,   // Unused
    output wire [7:0] uio_out,  // Unused
    output wire [7:0] uio_oe,   // Unused
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // Simple demo output so the tile is testable
    assign uo_out = ui_in ^ {ena, clk, rst_n, 5'b0};

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // ==================== 6 Performance Cores ====================
    // Each core: 4 RAM32 (dense L1-like) + repeated soft logic for striped stdcell datapath look
    genvar c, r;
    generate
        for (c = 0; c < 6; c = c + 1) begin : core_block
            // 4 RAM32 per core for small dense clusters
            for (r = 0; r < 4; r = r + 1) begin : core_ram
                RAM32 ram_inst (
                    .CLK(clk),
                    .A(5'd0),
                    .D(32'd0),
                    .WE(1'b0),
                    .Q()
                );
            end

            // Heavy soft logic filler for classic striped core appearance
            genvar i;
            for (i = 0; i < 48; i = i + 1) begin : datapath
                reg [31:0] chain_reg;
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) chain_reg <= {ui_in, 24'(i)};
                    else chain_reg <= chain_reg + 32'd1;
                end
            end
        end
    endgenerate

    // ==================== Large Shared L3 Cache (Central) ====================
    // 36 RAM32 arranged in a tight grid for one big dense central block
    generate
        for (r = 0; r < 36; r = r + 1) begin : l3_cache
            RAM32 ram_inst (
                .CLK(clk),
                .A(5'd0),
                .D(32'd0),
                .WE(1'b0),
                .Q()
            );
        end
    endgenerate

    // ==================== Memory Controller (Bottom horizontal) ====================
    // 16 RAM32 in a wide row for bottom block
    generate
        for (r = 0; r < 16; r = r + 1) begin : mem_ctrl
            RAM32 ram_inst (
                .CLK(clk),
                .A(5'd0),
                .D(32'd0),
                .WE(1'b0),
                .Q()
            );
        end
    endgenerate

    // ==================== Uncore / I/O (Top horizontal) ====================
    // 12 RAM32 in a wide row for top block
    generate
        for (r = 0; r < 12; r = r + 1) begin : uncore
            RAM32 ram_inst (
                .CLK(clk),
                .A(5'd0),
                .D(32'd0),
                .WE(1'b0),
                .Q()
            );
        end
    endgenerate

endmodule

`default_nettype wire
