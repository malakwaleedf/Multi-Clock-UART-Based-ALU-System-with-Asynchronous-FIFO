module deserializer (
    input CLK, // design clock
    input RST, // asynch reset
    input deser_en, // input signal to enable the module 
    input sampled_bit, // input signal holding the value of the sampled bit
    input sampled_bit_ready, // input signal to indicate that the sampled bit is ready
    output reg [7:0] P_DATA // output bus holding the received 8 bit data
);

    reg [2:0] counter; // internal bus to count 8 bits of serial data
    reg done; // internal signal to indicate counter is done

    // serial data changed into parallel
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            P_DATA <= 8'b0;
            done <= 1'b0;
        end
        else if(deser_en && sampled_bit_ready) begin
            P_DATA [counter] <= sampled_bit;
            if(counter == 3'b111) begin
                done <= 1'b1;
            end
            else begin
                done <= 1'b0;
            end
        end
        else begin
            done <= 1'b0;
        end
    end

    // counter logic
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            counter <= 3'b0;
        end
        else if(deser_en && sampled_bit_ready && !done) begin
            counter <= counter + 1'b1;
        end
        else if(done) begin
            counter <= 3'b0;
        end
    end
    
endmodule