module serializer(
    input [7:0] P_DATA, // input data
    input ser_en, // input signal to enable the serializer
    input CLK, // design clock
    input RST, // asynch reset
    input busy, // input signal to indicate that data transmission is happening 
    input Data_Valid,  // input signal to indicate the exictance of valid data, controls FSM state transission
    output ser_done, // output signal to indicate that the serial data bits are done 
    output ser_data // output serial data
);
    reg [2:0] count; // counter value
    reg [7:0] data_reg; // to hold input data to avoid glitches 

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            data_reg <= 8'b0;
        end
        else if(Data_Valid && !busy) begin
            data_reg <= P_DATA;
        end
        else if(ser_en) begin
            data_reg <= data_reg >> 1 ; 
        end
    end

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            count <= 3'b0;
        end
        else begin
            if(ser_en) begin
                count <= count + 1'b1;
            end
            else begin
                count <= 1'b0;
            end
        end
    end

    assign ser_done = (count == 'b111) ? 1'b1 : 1'b0 ;

    assign ser_data = data_reg[0] ;    

endmodule
 