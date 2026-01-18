/*
 * tt_um_bluewatercrystal_sexy_grid.v
 * AMD Style Chiplet Edition - High Density Layout
 */

`default_nettype none

// MODULE NAME UPDATED TO MATCH INFO.YAML
module tt_um_bluewatercrystal_sexy_grid (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Wires to collect results from the 4 Clusters
    wire [7:0] cluster_out [3:0];

    // ==========================================
    // THE "CHIPLET" GRID (4 SECTIONS)
    // ==========================================
    
    // Top-Left Cluster
    core_cluster #(.SEED_OFFSET(0)) cluster_0 (
        .clk(clk), .rst_n(rst_n), .global_seed(ui_in), .data_out(cluster_out[0])
    );

    // Top-Right Cluster
    core_cluster #(.SEED_OFFSET(16)) cluster_1 (
        .clk(clk), .rst_n(rst_n), .global_seed(ui_in), .data_out(cluster_out[1])
    );

    // Bottom-Left Cluster
    core_cluster #(.SEED_OFFSET(32)) cluster_2 (
        .clk(clk), .rst_n(rst_n), .global_seed(ui_in), .data_out(cluster_out[2])
    );

    // Bottom-Right Cluster
    core_cluster #(.SEED_OFFSET(48)) cluster_3 (
        .clk(clk), .rst_n(rst_n), .global_seed(ui_in), .data_out(cluster_out[3])
    );

    // Output Mixing
    assign uo_out = cluster_out[0] ^ cluster_out[1] ^ cluster_out[2] ^ cluster_out[3];
    
    assign uio_out = 0;
    assign uio_oe  = 0;
    wire _unused = &{ena, uio_in};

endmodule


/*
 * MODULE: Core Cluster (The "Section")
 * Contains a 4x4 grid of cores (16 total).
 */
module core_cluster #(parameter SEED_OFFSET = 0) (
    input wire clk,
    input wire rst_n,
    input wire [7:0] global_seed,
    output wire [7:0] data_out
);
    wire [7:0] results [15:0];
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : core_loop
            math_greeble_core u_core (
                .clk(clk),
                .rst_n(rst_n),
                .seed(global_seed + SEED_OFFSET + i[7:0]), 
                .data_out(results[i])
            );
        end
    endgenerate

    integer k;
    reg [7:0] cluster_mix;
    always @(*) begin
        cluster_mix = 0;
        for (k = 0; k < 16; k = k + 1) begin
            cluster_mix = cluster_mix ^ results[k];
        end
    end
    
    assign data_out = cluster_mix;
endmodule


/*
 * MODULE: The Leaf Core (The "Transistors")
 */
module math_greeble_core (
    input wire clk,
    input wire rst_n,
    input wire [7:0] seed,
    output reg [7:0] data_out
);
    reg [15:0] state;
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= {seed, seed};
            data_out <= 0;
        end else begin
            state <= {state[14:0], state[15] ^ state[13] ^ seed[0]};
            data_out <= state[15:8] + state[7:0] + seed;
        end
    end
endmodule
