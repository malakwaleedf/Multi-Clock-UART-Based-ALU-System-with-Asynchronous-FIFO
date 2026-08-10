module stop_check (
    input CLK, // design clock
    input RST, // asynch reset
    input stp_chk_en, // input signal to enable the module 
    input sampled_bit, // input signal holding the value of the sampled bit
    input sampled_bit_ready, // input signal to indicate that the sampled bit is ready
    output reg stp_err, // output signal to indicate if an error happens on the frame stop bit (comb)
    output reg Stop_Error // output signal to indicate if an error happens on the frame stop bit (inteface port)
);

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            Stop_Error <= 1'b0;
        end
        else if(stp_chk_en) begin
            Stop_Error <= stp_err;
        end
    end

    always @(*) begin
        stp_err = 1'b0;
        if(stp_chk_en && sampled_bit_ready) begin
            if(sampled_bit != 1) begin
                stp_err = 1'b1;
            end
        end
    end
    
endmodule