module edge_bit_counter (
    input enable, // input signal to enable the module 
    input PAR_EN, // input signal to configure the parity bit option, 0 -> no parity bit, 1 -> parity bit
    input [5:0] Prescaler, // input bus to configure the prescaler value 
    input CLK, // design clock
    input RST, // asynch reset
    output reg [3:0] bit_cnt, // output bus holding the current number of bits per frame
    output reg [4:0] edge_cnt // output bus holding the current number of edges per bit
);

    // prescaler values
    localparam prescaler_8 = 6'b00_1000;
    localparam prescaler_16 = 6'b01_0000;
    localparam prescaler_32 = 6'b10_0000;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            bit_cnt <= 4'b0;
            edge_cnt <= 5'b0;
        end
        else begin
            if(enable) begin
                edge_cnt <=  edge_cnt + 1'b1;
                case (Prescaler)
                prescaler_8: begin
                    if(edge_cnt == 5'b0_0111) begin
                        if(bit_cnt == 4'b1001 && !PAR_EN) begin // reset bit_cnt when it reach 9 when no parirty 
                            bit_cnt <= 4'b0;
                        end
                        else if(bit_cnt == 4'b1010 && PAR_EN) begin // reset bit_cnt when it reach 10 when parirty 
                            bit_cnt <= 4'b0;
                        end
                        else begin
                            bit_cnt <= bit_cnt + 1'b1; // bit_cnt is incremented when edge_cnt reaches 7
                            edge_cnt <= 5'b0; // reset  edge_cnt reaches 7
                        end
                    end
                end 
                prescaler_16: begin
                    if(edge_cnt == 5'b0_1111) begin
                        if(bit_cnt == 4'b1001 && !PAR_EN) begin // reset bit_cnt when it reach 9 when no parirty 
                            bit_cnt <= 4'b0;
                        end
                        else if(bit_cnt == 4'b1010 && PAR_EN) begin // reset bit_cnt when it reach 10 when parirty 
                            bit_cnt <= 4'b0;
                        end
                        else begin
                            bit_cnt <= bit_cnt + 1'b1; // bit_cnt is incremented when edge_cnt reaches 15
                            edge_cnt <= 5'b0; // reset  edge_cnt reaches 15
                        end
                    end
                end 
                prescaler_32: begin
                    if(edge_cnt == 5'b1_1111) begin
                        if(bit_cnt == 4'b1001 && !PAR_EN) begin // reset bit_cnt when it reach 9 when no parirty 
                            bit_cnt <= 4'b0;
                        end
                        else if(bit_cnt == 4'b1010 && PAR_EN) begin // reset bit_cnt when it reach 10 when parirty 
                            bit_cnt <= 4'b0;
                        end
                        else begin
                            bit_cnt <= bit_cnt + 1'b1; // bit_cnt is incremented when edge_cnt reaches 31
                            edge_cnt <= 5'b0; // reset  edge_cnt reaches 31
                        end
                    end
                end 
                default: begin
                    bit_cnt <= 4'b0;
                    edge_cnt <= 5'b0;
                end
                endcase
            end
            else begin
                edge_cnt <= 1'b0;
                bit_cnt <= 1'b0;
            end
        end
    end
endmodule