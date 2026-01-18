`default_nettype none
module core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] data_in,
    output wire [31:0] data_out
);
    // 16 Stages of 32-bit Logic
    reg [31:0] pipe [0:15];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 16; i = i + 1) pipe[i] <= 32'd0;
        end else begin
            pipe[0] <= data_in;
            for (i = 1; i < 16; i = i + 1) begin
                // The mixing of (+) and (^) forces complex logic gates
                pipe[i] <= (pipe[i-1] + 32'hDEAD_BEEF) ^ (i * 32'h1);
            end
        end
    end
    assign data_out = pipe[15];
endmodule
