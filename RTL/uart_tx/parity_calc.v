module parity_calc (
    input PAR_TYP, // input signal to configure the type of the parity, 0 -> even, 1 -> odd
    input Data_Valid, // input signal to indicate the exictance of valid data
    input busy, // input signal to indicate that data transmission is happening 
    input [7:0] P_DATA, // input data
    input CLK, // design clcok
    input RST, // asynch reset
    output reg par_bit // output parity bit value
);

    // PAR_TYP values
    localparam EVEN = 1'b0;
    localparam ODD = 1'b1;

    reg [7:0] data_reg; // to hold input data to avoid glitches 

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            data_reg <= 8'b0;
        end
        else if(Data_Valid && !busy) begin
            data_reg <= P_DATA;
        end
    end
    
    // par_bit calculation 
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            par_bit <= 1'b0;
        end
        else begin
            if(PAR_TYP == EVEN) begin
                par_bit <= ^data_reg;
            end
            else if (PAR_TYP == ODD) begin
                par_bit <= ~(^data_reg);
            end
        end
    end

endmodule