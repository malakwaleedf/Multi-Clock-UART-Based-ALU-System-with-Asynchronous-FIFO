module clk_gate (
    input CLK,
    input CLK_EN,
    output GATED_CLK
);

    reg lat_out;

    always @(*) begin
        if(!CLK) begin
           lat_out = CLK_EN; 
        end
    end

    assign GATED_CLK = lat_out && CLK;

    // TLATNCAX12M U0_TLATNCAX12M (
    //     .E(CLK_EN),
    //     .CK(CLK),
    //     .ECK(GATED_CLK)
    // );
    
endmodule