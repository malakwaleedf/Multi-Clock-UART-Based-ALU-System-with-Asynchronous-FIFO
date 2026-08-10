module start_check (
    input CLK, // design clock
    input RST, // asynch reset
    input strt_chk_en, // input signal to enable the module 
    input sampled_bit, // input signal holding the value of the sampled bit
    input sampled_bit_ready, // input signal to indicate that the sampled bit is ready
    output reg strt_glitch // output signal to indicate if a glitch happens on the frame start bit
);

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            strt_glitch <= 1'b0;
        end
        else if(strt_chk_en && sampled_bit_ready) begin
            if(sampled_bit != 0) begin
                strt_glitch <= 1'b1;
            end
        end
    end
    
endmodule