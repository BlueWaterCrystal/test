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

    wire [31:0] core_res [0:5];   
    wire [31:0] ram_res  [0:1];   
    wire [31:0] l3_res   [0:3];   

    // 6 Cores (Stripes)
    genvar c;
    generate
        for (c = 0; c < 6; c = c + 1) begin : gen_cores
            core u_core (.clk(clk), .rst_n(rst_n), .data_in(seed + c), .data_out(core_res[c]));
        end
    endgenerate

    // 4 L3 Banks (Center Mass)
    genvar l;
    generate
        for (l = 0; l < 4; l = l + 1) begin : gen_l3
            sharedl3 u_l3 (.clk(clk), .rst_n(rst_n), .bus_in(seed ^ l), .cache_out(l3_res[l]));
        end
    endgenerate

    // 2 RAM Controllers (Bottom Bars)
    genvar r;
    generate
        for (r = 0; r < 2; r = r + 1) begin : gen_ram
            ram32 u_ram (.clk(clk), .rst_n(rst_n), .addr_in(seed - r), .data_out(ram_res[r]));
        end
    endgenerate

    // The "Internet" Bus
    wire [31:0] global_bus;
    assign global_bus = core_res[0] ^ core_res[1] ^ core_res[2] ^ core_res[3] ^ core_res[4] ^ core_res[5] ^
                        l3_res[0]   ^ l3_res[1]   ^ l3_res[2]   ^ l3_res[3] ^
                        ram_res[0]  ^ ram_res[1];

    assign uo_out = global_bus[31:24] ^ global_bus[23:16] ^ global_bus[15:8] ^ global_bus[7:0];

endmodule
