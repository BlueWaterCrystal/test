module core (
    input  wire clk,
    input  wire rst_n,
    output wire [7:0] dummy_out  // Connect to top-level outputs if you want visibility
);
    reg [31:0] counter;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) counter <= 0;
        else counter <= counter + 1;
    end
    assign dummy_out = counter[31:24];

    // Add repeated logic for better visual fill/stripes (50 chains of flops/adders)
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : datapath
            reg [15:0] chain;
            always @(posedge clk) begin
                chain <= chain + i[7:0];
            end
        end
    endgenerate
endmodule
