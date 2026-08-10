module uart_top(
    input TX_CLK,  // UART TX Clock Signal
    input RX_CLK, // UART RX Clock Signal
    input RST, // Synchronized reset signal
    input PAR_TYP, // Parity Type
    input PAR_EN, // Parity_Enable
    input [5:0] Prescaler, // Oversampling Prescale

    input [7:0] TX_IN_P, // Input TX data byte (parallel)
    input TX_IN_V, // Input TX data valid signal
    output TX_OUT_S, // TX Frame Serial Out (serial)
    output TX_OUT_V, // TX Out Valid signal

    input RX_IN_S, // Input RX UART frame (serial)
    output [7:0] RX_OUT_P, // RX Out Data (parallel)
    output RX_OUT_V, // RX Out Data Valid signal

    output Parity_Error,
    output Stop_Error
);

uart_tx_top uart_tx_top_inst (
    .P_DATA(TX_IN_P), // input data
    .DATA_VALID(TX_IN_V), // input signal to indicate the exictance of valid data
    .PAR_EN(PAR_EN), // input signal to configure the parity bit option, 0 -> no parity bit, 1 -> parity bit
    .PAR_TYP(PAR_TYP), // input signal to configure the type of the parity, 0 -> even, 1 -> odd
    .CLK(TX_CLK), // design clock
    .RST(RST), // asynch reset
    .TX_OUT(TX_OUT_S), // output signal
    .BUSY(TX_OUT_V) // output signal to indicate that data transmission is happening 
);

uart_rx_top uart_rx_top_inst (
    .RX_IN(RX_IN_S), // input design serial in data
    .PAR_EN(PAR_EN), // input signal to configure the parity bit option, 0 -> no parity bit, 1 -> parity bit
    .PAR_TYP(PAR_TYP), // input signal to configure the type of the parity, 0 -> even, 1 -> odd
    .Prescaler(Prescaler), // input bus to configure the prescaler value 
    .CLK(RX_CLK), // design clock
    .RST(RST), // asynch reset
    .P_DATA(RX_OUT_P), // output bus holding the received 8 bit data
    .Data_valid(RX_OUT_V), // output signal to indicate the parallel data is valid on P_DATA bus
    .Parity_Error(Parity_Error), // output signal to indicate if an error happens on the frame parity bit
    .Stop_Error(Stop_Error) // output signal to indicate if an error happens on the frame stop bit 
);

endmodule