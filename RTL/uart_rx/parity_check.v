module parity_check (
    input CLK, // design clock
    input RST, // asynch reset
    input PAR_TYP, // input signal to configure the type of the parity, 0 -> even, 1 -> odd
    input par_chk_en, // input signal to enable the module 
    input sampled_bit, // input signal holding the value of the sampled bit
    input sampled_bit_ready, // input signal to indicate that the sampled bit is ready
    input [7:0] P_DATA, // input bus holding the received 8 bit data
    output par_err, // output signal to indicate if an error happens on the frame parity bit (comb)
    output reg Parity_Error // output signal to indicate if an error happens on the frame parity bit (inteface port)
);
    // PAR_TYP values
    localparam EVEN = 1'b0;
    localparam ODD = 1'b1;

    reg received_par; // internal signal to hold the received parity bit
    reg calculated_par; // internal signal to hold the calculated parity bit

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            Parity_Error <= 1'b0;
        end
        else if(par_chk_en) begin
            Parity_Error <= par_err;
        end
    end

    always @(*) begin
        received_par = 1'b0;
        calculated_par = 1'b0;
        if(par_chk_en && sampled_bit_ready) begin
            received_par = sampled_bit;
            if(PAR_TYP == EVEN) begin
                calculated_par = ^P_DATA;
            end
            else if (PAR_TYP == ODD) begin
                calculated_par = ~(^P_DATA);
            end
        end
    end

    assign par_err = (received_par == calculated_par)? 1'b0 : 1'b1;
    
endmodule