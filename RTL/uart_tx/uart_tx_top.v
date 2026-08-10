module uart_tx_top (
    input [7:0] P_DATA, // input data
    input DATA_VALID, // input signal to indicate the exictance of valid data
    input PAR_EN, // input signal to configure the parity bit option, 0 -> no parity bit, 1 -> parity bit
    input PAR_TYP, // input signal to configure the type of the parity, 0 -> even, 1 -> odd
    input CLK, // design clock
    input RST, // asynch reset
    output TX_OUT, // output signal
    output BUSY // output signal to indicate that data transmission is happening 
);

    wire ser_done; // internal signal from serializer to FSM, indicates that the serial data is done
    wire ser_en; // internal signal from FSM to serializer, to start parallel to serial conversion
    wire [1:0] mux_sel; // mux select signals
    wire par_bit; // calculated partiy bit input to mux
    wire ser_data; // internal serial data bit input to mux

    uart_tx_fsm FSM_block(
        .Data_Valid(DATA_VALID),
        .PAR_EN(PAR_EN),
        .ser_done(ser_done),
        .CLK(CLK),
        .RST(RST),
        .mux_sel(mux_sel),
        .busy(BUSY),
        .ser_en(ser_en)
    );

    parity_calc parity_block(
        .PAR_TYP(PAR_TYP),
        .Data_Valid(DATA_VALID),
        .busy(BUSY),
        .P_DATA(P_DATA),
        .CLK(CLK),
        .RST(RST),
        .par_bit(par_bit)
    );
    
    mux_4 mux_block(
        .mux_sel(mux_sel),
        .start_bit(1'b0),
        .stop_bit(1'b1),
        .ser_data(ser_data),
        .par_bit(par_bit),
        .CLK(CLK),
        .RST(RST),
        .TX_OUT(TX_OUT)
    );

    serializer serializer_block(
        .P_DATA(P_DATA),
        .ser_en(ser_en),
        .CLK(CLK),
        .RST(RST),
        .busy(BUSY),
        .Data_Valid(DATA_VALID),
        .ser_done(ser_done),
        .ser_data(ser_data)
    );

endmodule