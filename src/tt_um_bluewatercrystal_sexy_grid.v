`default_nettype none

module tt_um_bluewatercrystal_sexy_grid (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // Simple testable output
    assign uo_out = ui_in ^ {ena, clk, rst_n, 5'b0};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // ==================== 6 Performance Cores (striped datapath texture) ====================
    genvar c, i;
    generate
        for (c = 0; c < 6; c = c + 1) begin : core_block
            // Wide parallel chains for strong horizontal/vertical stripes
            for (i = 0; i < 120; i = i + 1) begin : datapath
                reg [31:0] chain;
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) chain <= {ui_in, 24'(c + i)};
                    else chain <= chain + 32'(i[7:0]);
                end
            end
        end
    endgenerate

    // ==================== Large Shared L3 Cache (dense grid texture) ====================
    genvar x, y;
    generate
        for (x = 0; x < 30; x = x + 1) begin : l3_row
            for (y = 0; y < 30; y = y + 1) begin : l3_cell
                reg [15:0] cell;
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) cell <= {x[4:0], y[4:0], 6'b0};
                    else cell <= cell + 16'(x + y);
                end
            end
        end
    endgenerate

    // ==================== Memory Controller (wide horizontal rows) ====================
    genvar m;
    generate
        for (m = 0; m < 80; m = m + 1) begin : mem_ctrl
            reg [63:0] wide_chain;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) wide_chain <= 64'(m);
                else wide_chain <= {wide_chain[62:0], wide_chain[63] ^ rst_n};
            end
        end
    endgenerate

    // ==================== Uncore / I/O (mixed dense filler) ====================
    genvar u;
    generate
        for (u = 0; u < 60; u = u + 1) begin : uncore
            reg [23:0] mix_reg;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) mix_reg <= {ui_in, 16'(u)};
                else mix_reg <= mix_reg ^ {mix_reg[22:0], clk};
            end
        end
    endgenerate

endmodule

`default_nettype wire
