module mux_4 (
    input [1:0] mux_sel, // input signals to select which bit type to be output (start, stop, data, parity)
    input start_bit, // start bit value
    input stop_bit, // stop bit value
    input ser_data, // serial data
    input par_bit, // parity bit value
    input CLK, // design clock
    input RST, // asynch reset
    output reg TX_OUT // output signal
);

    reg TX_OUT_comb;
    
    // MUX selections
    localparam START_BIT = 2'b00;
    localparam STOP_BIT = 2'b01;
    localparam DATA = 2'b10;
    localparam PARITY_BIT = 2'b11;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            TX_OUT <= 1'b1;
        end
        else begin
            TX_OUT <= TX_OUT_comb;
        end
    end

    always @(*) begin
        case (mux_sel)
        START_BIT: TX_OUT_comb = start_bit;
        STOP_BIT: TX_OUT_comb = stop_bit;
        DATA: TX_OUT_comb = ser_data;
        PARITY_BIT: TX_OUT_comb = par_bit;
        default: TX_OUT_comb = 1'b1; // for idle TX_OUT
        endcase
    end

endmodule