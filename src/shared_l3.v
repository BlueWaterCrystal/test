`default_nettype none
module sharedl3 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] bus_in,
    output wire [31:0] cache_out
);
    reg [31:0] cell_a;
    reg [31:0] cell_b;
    reg [31:0] cell_c;
    reg [31:0] cell_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cell_a <= 0; cell_b <= 0; cell_c <= 0; cell_d <= 0;
        end else begin
            // 4-stage feedback mess = High Density Logic
            cell_a <= bus_in ^ cell_b;
            cell_b <= cell_a + cell_c;
            cell_c <= cell_b ^ cell_d;
            cell_d <= cell_c + 32'hA5A5A5A5;
        end
    end
    assign cache_out = cell_d;
endmodule
