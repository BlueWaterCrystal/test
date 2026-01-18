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

    // Tie off unused pins
    assign uio_oe  = 8'b11111111;
    assign uio_out = 8'b0;

    // --- INTERCONNECT WIRES ---
    wire [31:0] core_res [0:5];   // 6 Cores
    wire [31:0] ram_res  [0:1];   // 2 RAM Controllers
    wire [31:0] l3_res   [0:3];   // 4 L3 Banks

    // --- INSTANTIATE 6 CORES ---
    genvar c;
    generate
        for (c = 0; c < 6; c = c + 1) begin : gen_cores
            core u_core (
                .clk(clk),
                .rst_n(rst_n),
                .data_in({24'b0, ui_in} + c), // Unique seed per core
                .data_out(core_res[c])
            );
        end
    endgenerate

    // --- INSTANTIATE 4 L3 BANKS ---
    genvar l;
    generate
        for (l = 0; l < 4; l = l + 1) begin : gen_l3
            sharedl3 u_l3 (
                .clk(clk),
                .rst_n(rst_n),
                .bus_in({24'b0, uio_in} ^ l),
                .cache_out(l3_res[l])
            );
        end
    endgenerate

    // --- INSTANTIATE 2 RAM CONTROLLERS ---
    genvar r;
    generate
        for (r = 0; r < 2; r = r + 1) begin : gen_ram
            ram32 u_ram (
                .clk(clk),
                .rst_n(rst_n),
                .addr_in({24'b0, ui_in} - r),
                .data_out(ram_res[r])
            );
        end
    endgenerate

    // --- THE INTERNET CONNECTION (Global XOR Bus) ---
    // We XOR *everything* to the output. This forces the placer to run wires 
    // from every single block to this final point, creating the web of connectivity.
    
    wire [31:0] global_bus;
    
    assign global_bus = core_res[0] ^ core_res[1] ^ core_res[2] ^ 
                        core_res[3] ^ core_res[4] ^ core_res[5] ^
                        l3_res[0]   ^ l3_res[1]   ^ l3_res[2]   ^ l3_res[3] ^
                        ram_res[0]  ^ ram_res[1];

    assign uo_out = global_bus[7:0];

endmodule
