module fsm_uart_rx (
    input RX_IN, // input signal serial in data
    input PAR_EN, // input signal to configure the parity bit option, 0 -> no parity bit, 1 -> parity bit
    input [3:0] bit_cnt, // input bus holding the current number of bits per frame
    input strt_glitch, // input signal to indicate if a glitch happens on the frame start bit
    input par_err, // input signal to indicate if an error happens on the frame parity bit
    input stp_err, // input signal to indicate if an error happens on the frame stop bit
    input CLK, // design clock
    input RST, // asynch reset
    output reg data_valid, // output signal to indicate the parallel data is valid on P_DATA bus
    output reg dat_samp_en, // output signal to enable data_sampling module 
    output reg enable, // output signal to enable edge_bit_counter module 
    output reg deser_en, // output signal to enable deserializer module 
    output reg strt_chk_en, // output signal to enable start_check module 
    output reg par_chk_en, // output signal to enable parity_check module 
    output reg stp_chk_en // output signal to enable stop_check module 
);

    // FSM states
    localparam IDLE = 6'b00_0001;
    localparam START = 6'b00_0010;
    localparam DATA = 6'b00_0100;
    localparam PARITY = 6'b00_1000;
    localparam STOP = 6'b01_0000;
    localparam OUT = 6'b10_0000;

    reg [5:0] cs, ns; // FSM current and next states
    reg data_valid_comb; // internal signal to hold comb data_valid signal
    reg rx_in_old; // internal signal to hold previous clk edge value of the input RX_IN, helps in frame start condition

    // current state update
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            cs <= IDLE;
            rx_in_old <= 1'b1;
        end
        else begin
            cs <= ns;
            rx_in_old <= RX_IN;
        end
    end

    // next state logic
    always @(*) begin
        case (cs)
        IDLE: begin
            if(!RX_IN && rx_in_old) begin // if a falling edge is detected 
                ns = START;
            end
            else begin
                ns = IDLE;
            end
        end 
        START: begin
            if(bit_cnt == 4'b1 && !strt_glitch) begin // after 1st bit and no start bit glitching
                ns = DATA;
            end
            else if(bit_cnt == 4'b1 && strt_glitch) begin // after 1st bit and start bit glitching
                ns = IDLE;
            end
            else begin
                ns = START;
            end
        end
        DATA: begin
            if(bit_cnt == 4'b1001 && PAR_EN) begin // after 8 bits of data with parity enabled 
                ns = PARITY;
            end
            else if(bit_cnt == 4'b1001 && !PAR_EN) begin // after 8 bits of data without parity enabled 
                ns = STOP;
            end
            else begin
                ns = DATA;
            end
        end
        PARITY: begin
            if(bit_cnt == 4'b1010 && !par_err) begin // after 9th bit and no parity bit error
                ns = STOP;
            end
            else if(bit_cnt == 4'b1010 && par_err) begin // after 9th bit and parity bit error
                ns = IDLE;
            end
            else begin
                ns = PARITY;
            end
        end
        STOP: begin
            if(bit_cnt == 4'b0 && !stp_err) begin // after last bit and no stop bit error
                ns = OUT;
                // if(!RX_IN && rx_in_old) begin // if a falling edge is detected 
                //     ns = START; // to enable consequtive frames logic
                // end
                // else begin
                //     ns = IDLE;
                // end
            end
            else if(bit_cnt == 4'b0 && stp_err) begin // after last bit and stop bit error
                ns = IDLE;
            end
            else begin
                ns = STOP;
            end
        end
        OUT: begin
            if(!RX_IN && rx_in_old) begin // if a falling edge is detected 
                ns = START; // to enable consequtive frames logic
            end
            else begin
                ns = IDLE;
            end
        end
        default: begin
            ns = IDLE;
        end
        endcase
    end

    // output signals logic
    always @(*) begin
        data_valid_comb = 1'b0;
        dat_samp_en = 1'b0;
        enable = 1'b0;
        deser_en = 1'b0;
        strt_chk_en = 1'b0;
        par_chk_en = 1'b0;
        stp_chk_en = 1'b0;
        case (cs)
        IDLE: begin
        end
        START: begin
            dat_samp_en = 1'b1; // enable data_sampling
            enable = 1'b1; // enbale edge_bit_counter
            strt_chk_en = 1'b1; // enbale start_check
        end
        DATA: begin
            dat_samp_en = 1'b1; // enable data_sampling
            enable = 1'b1; // enbale edge_bit_counter
            deser_en = 1'b1; // enbale deserializer
        end
        PARITY: begin
            dat_samp_en = 1'b1; // enable data_sampling
            enable = 1'b1; // enbale edge_bit_counter
            par_chk_en = 1'b1; // enbale parity_check
        end
        STOP: begin
            dat_samp_en = 1'b1; // enable data_sampling
            enable = 1'b1; // enbale edge_bit_counter
            stp_chk_en = 1'b1; // enbale stop_check
            // data_valid_comb = 1'b1; // data is valid
        end
        OUT: begin
            data_valid_comb = 1'b1; // data is valid
        end
        default: begin
        end
        endcase
    end

    // registered data_valid
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            data_valid <= 1'b0;
        end
        else begin
            data_valid <= data_valid_comb;
        end
    end

endmodule