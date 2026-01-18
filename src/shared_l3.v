module shared_l3 (
    input wire clk,
    input wire rst_n
    // Add ports if you want functionality; for pure visuals, keep minimal
);
    // Instance 12-16 RAM32 macros - they'll form a dense central cache block
    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin : cache_bank
            RAM32 bank (
                .CLK(clk),
                .A(5'd0),    // Dummy connections (for visuals only)
                .D(32'd0),
                .WE(1'b0),
                .Q()
            );
        end
    endgenerate
endmodule
