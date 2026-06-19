`default_nettype none
module tt_um_bluewatercrystal_sexy_grid (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    // Condition inputs
    wire [31:0] seed = {ui_in, uio_in, ui_in, uio_in} ^ {32{ena}};

    assign uio_oe  = 8'b11111111;
    assign uio_out = 8'b0;

    // Explicit wires for routing
    wire [31:0] core_res_0, core_res_1, core_res_2, core_res_3, core_res_4, core_res_5;
    wire [31:0] l3_res_0, l3_res_1, l3_res_2, l3_res_3;
    wire [31:0] ram_res_0, ram_res_1;

    // 6 Cores (Stripes) - Explicitly instantiated for easy macro placement
    core core_0 (.clk(clk), .rst_n(rst_n), .data_in(seed + 32'd0), .data_out(core_res_0));
    core core_1 (.clk(clk), .rst_n(rst_n), .data_in(seed + 32'd1), .data_out(core_res_1));
    core core_2 (.clk(clk), .rst_n(rst_n), .data_in(seed + 32'd2), .data_out(core_res_2));
    core core_3 (.clk(clk), .rst_n(rst_n), .data_in(seed + 32'd3), .data_out(core_res_3));
    core core_4 (.clk(clk), .rst_n(rst_n), .data_in(seed + 32'd4), .data_out(core_res_4));
    core core_5 (.clk(clk), .rst_n(rst_n), .data_in(seed + 32'd5), .data_out(core_res_5));

    // 4 L3 Banks (Center Mass)
    shared_l3 l3_0 (.clk(clk), .rst_n(rst_n), .bus_in(seed ^ 32'd0), .cache_out(l3_res_0));
    shared_l3 l3_1 (.clk(clk), .rst_n(rst_n), .bus_in(seed ^ 32'd1), .cache_out(l3_res_1));
    shared_l3 l3_2 (.clk(clk), .rst_n(rst_n), .bus_in(seed ^ 32'd2), .cache_out(l3_res_2));
    shared_l3 l3_3 (.clk(clk), .rst_n(rst_n), .bus_in(seed ^ 32'd3), .cache_out(l3_res_3));

    // 2 RAM Controllers (Bottom Bars)
    ram32 ram_0 (.clk(clk), .rst_n(rst_n), .addr_in(seed - 32'd0), .data_out(ram_res_0));
    ram32 ram_1 (.clk(clk), .rst_n(rst_n), .addr_in(seed - 32'd1), .data_out(ram_res_1));

    // The "Internet" Bus connecting them all together
    wire [31:0] global_bus;
    assign global_bus = core_res_0 ^ core_res_1 ^ core_res_2 ^ core_res_3 ^ core_res_4 ^ core_res_5 ^
                        l3_res_0   ^ l3_res_1   ^ l3_res_2   ^ l3_res_3   ^
                        ram_res_0  ^ ram_res_1;

    assign uo_out = global_bus[31:24] ^ global_bus[23:16] ^ global_bus[15:8] ^ global_bus[7:0];

endmodule
