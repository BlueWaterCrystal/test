`default_nettype none

module core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] data_in,
    output wire [31:0] data_out
);

    // 20 stages of arithmetic logic to create "striped" logic texture
    reg [31:0] pipe [0:19];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 20; i = i + 1) pipe[i] <= 32'd0;
        end else begin
            // Stage 0: Load
            pipe[0] <= data_in;
            
            // Stages 1-19: Arithmetic Chains
            for (i = 1; i < 20; i = i + 1) begin
                pipe[i] <= pipe[i-1] + 32'hDEAD_BEEF + (i * 32'h1);
            end
        end
    end

    assign data_out = pipe[19];

endmodule
