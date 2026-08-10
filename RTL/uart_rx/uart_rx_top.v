module uart_rx_top (
    input RX_IN, // input design serial in data
    input PAR_EN, // input signal to configure the parity bit option, 0 -> no parity bit, 1 -> parity bit
    input PAR_TYP, // input signal to configure the type of the parity, 0 -> even, 1 -> odd
    input [5:0] Prescaler, // input bus to configure the prescaler value 
    input CLK, // design clock
    input RST, // asynch reset
    output [7:0] P_DATA, // output bus holding the received 8 bit data
    output Data_valid, // output signal to indicate the parallel data is valid on P_DATA bus
    output Parity_Error, // output signal to indicate if an error happens on the frame parity bit
    output Stop_Error // output signal to indicate if an error happens on the frame stop bit 
);

    wire [3:0] bit_cnt;
    wire [4:0] edge_cnt;
    wire strt_glitch, par_err, stp_err;
    wire strt_chk_en, par_chk_en, stp_chk_en;
    wire dat_samp_en, enable, deser_en;
    wire sampled_bit, sampled_bit_ready;

    fsm_uart_rx FSM (
        .RX_IN(RX_IN),
        .PAR_EN(PAR_EN),
        .bit_cnt(bit_cnt),
        .strt_glitch(strt_glitch),
        .par_err(par_err), 
        .stp_err(stp_err),
        .CLK(CLK),
        .RST(RST),
        .data_valid(Data_valid),
        .dat_samp_en(dat_samp_en),
        .enable(enable),
        .deser_en(deser_en),
        .strt_chk_en(strt_chk_en),
        .par_chk_en(par_chk_en),
        .stp_chk_en(stp_chk_en)
    );

    edge_bit_counter EDGE_BIT_COUNTER (
        .enable(enable),
        .PAR_EN(PAR_EN),
        .Prescaler(Prescaler),
        .CLK(CLK),
        .RST(RST),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt)
    );

    data_sampling DATA_SAMPLING (
        .RX_IN(RX_IN),
        .Prescaler(Prescaler),
        .CLK(CLK),
        .RST(RST),
        .edge_cnt(edge_cnt),
        .dat_samp_en(dat_samp_en),
        .sampled_bit(sampled_bit),
        .sampled_bit_ready(sampled_bit_ready)
    );

    deserializer DESERIALIZER (
        .CLK(CLK),
        .RST(RST), 
        .deser_en(deser_en),
        .sampled_bit(sampled_bit),
        .sampled_bit_ready(sampled_bit_ready),
        .P_DATA(P_DATA)
    );

    start_check START_CHECK (
        .CLK(CLK),
        .RST(RST),
        .strt_chk_en(strt_chk_en),
        .sampled_bit(sampled_bit),
        .sampled_bit_ready(sampled_bit_ready),
        .strt_glitch(strt_glitch)
    );

    stop_check STOP_CHECK (
        .CLK(CLK),
        .RST(RST),
        .stp_chk_en(stp_chk_en),
        .sampled_bit(sampled_bit),
        .sampled_bit_ready(sampled_bit_ready),
        .stp_err(stp_err),
        .Stop_Error(Stop_Error)
    );

    parity_check PARITY_CHECK (
        .CLK(CLK),
        .RST(RST),
        .PAR_TYP(PAR_TYP),
        .par_chk_en(par_chk_en),
        .sampled_bit(sampled_bit),
        .sampled_bit_ready(sampled_bit_ready),
        .P_DATA(P_DATA),
        .par_err(par_err),
        .Parity_Error(Parity_Error)
    );

endmodule