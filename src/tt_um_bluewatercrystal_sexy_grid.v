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

    // Demo output
    assign uo_out = ui_in ^ {ena, clk, rst_n, 5'b0};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // 6 Cores: striped datapaths (moderate density for clear stripes + separation)
    genvar c, i;
    generate
        for (c = 0; c < 6; c = c + 1) begin : core_block
            for (i = 0; i < 80; i = i + 1) begin : datapath
                reg [31:0] chain;
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) chain <= {ui_in, 24'(c*80 + i)};
                    else chain <= chain + 32'(i);
                end
            end
        end
    endgenerate

    // Huge Central Shared L3: ultra-dense grid (60x60 = 3600 regs → massive packed block)
    genvar x, y;
    generate
        for (x = 0; x < 60; x = x + 1) begin : l3_row
            for (y = 0; y < 60; y = y + 1) begin : l3_cell
                reg [15:0] cell;
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) cell <= {x[5:0], y[5:0], 4'b0};
                    else cell <= cell + 16'(x ^ y);
                end
            end
        end
    endgenerate

    // Memory Controller: wide horizontal chains (long rows for bottom bar texture)
    genvar m;
    generate
        for (m = 0; m < 120; m = m + 1) begin : mem_ctrl
            reg [63:0] wide_chain;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) wide_chain <= 64'(m * {8{ui_in[0]}});
                else wide_chain <= {wide_chain[62:0], wide_chain[63]};  // rotate left
            end
        end
    endgenerate

    // Uncore/I/O: mixed dense filler (top varied texture)
    genvar u;
    generate
        for (u = 0; u < 80; u = u + 1) begin : uncore
            reg [31:0] mix_reg;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) mix_reg <= {ui_in, ui_in, 16'(u)};
                else mix_reg <= mix_reg ^ 32'(u + clk);
            end
        end
    endgenerate

endmodule

`default_nettype wire
