module mux4 #(
    parameter SELECT_SIZE = 6,
    parameter OUTPUT_SIZE = 8
)(
    input [SELECT_SIZE-1 : 0] select, // precaler value
    output reg [OUTPUT_SIZE-1 : 0] MUX_OUT // div ratio for RX clk
);

    always @(*) begin
        case (select)
        'd32: MUX_OUT = 'd1; 
        'd16: MUX_OUT = 'd2; 
        'd8: MUX_OUT = 'd4; 
        default: MUX_OUT = 'd1; 
        endcase
    end
    
endmodule