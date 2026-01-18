`default_nettype none

module sharedl3 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] bus_in,
    output wire [31:0] cache_out
);

    // Dense XOR grid
    reg [31:0] cell_a;
    reg [31:0] cell_b;
    reg [31:0] cell_c;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cell_a <= 0;
            cell_b <= 0;
            cell_c <= 0;
        end else begin
            // Feedback loop to create a dense "furball" of logic
            cell_a <= bus_in ^ cell_b;
            cell_b <= cell_a ^ cell_c ^ 32'hA5A5A5A5;
            cell_c <= cell_b + 32'd1;
        end
    end

    assign cache_out = cell_c;

endmodule
