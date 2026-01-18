`default_nettype none

module ram32 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] addr_in,
    output wire [31:0] data_out
);

    // Wide shift register to create "blocky" memory texture
    reg [31:0] mem_chain [0:15];
    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < 16; k = k + 1) mem_chain[k] <= 32'd0;
        end else begin
            mem_chain[0] <= addr_in;
            for (k = 1; k < 16; k = k + 1) begin
                // Rotate bits to prevent optimization
                mem_chain[k] <= {mem_chain[k-1][30:0], mem_chain[k-1][31]};
            end
        end
    end

    assign data_out = mem_chain[15];

endmodule
