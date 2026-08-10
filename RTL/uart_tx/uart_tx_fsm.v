module uart_tx_fsm (
    input Data_Valid, // input signal to indicate the exictance of valid data, controls FSM state transission
    input PAR_EN, // input signal to configure the parity bit option, 0 -> no parity bit, 1 -> parity bit
    input ser_done, // input signal from the serializer module to indicate that the serial data bits are done 
    input CLK, // design clock
    input RST, // asynch reset
    output reg [1:0] mux_sel, // output signals to select which bit type to be output (start, stop, data, parity)
    output reg busy, // output signal to indicate that data transmission is happening 
    output reg ser_en // output signal to enable the serializer module
);

    // FSM states
    localparam IDLE = 5'b0_0001;
    localparam START = 5'b0_0010;
    localparam DATA_TRANSFER = 5'b0_0100;
    localparam PARITY = 5'b0_1000;
    localparam STOP = 5'b1_0000;

    // MUX selections
    localparam START_BIT = 2'b00;
    localparam STOP_BIT = 2'b01;
    localparam DATA = 2'b10;
    localparam PARITY_BIT = 2'b11;

    reg [4:0] cs, ns; // FSM current and next states
    reg busy_comb;

    // current state update
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            cs <= IDLE;
        end
        else begin
            cs <= ns;
        end
    end

    // next state logic
    always @(*) begin
        case (cs)
        IDLE: begin
            if(Data_Valid) begin
                ns = START;
            end
            else begin
                ns = IDLE;
            end
        end 
        START: begin
            ns = DATA_TRANSFER;
        end
        DATA_TRANSFER: begin
            if(ser_done && PAR_EN) begin
                ns = PARITY;
            end
            else if(ser_done && !PAR_EN) begin
                ns = STOP;
            end
            else begin
                ns = DATA_TRANSFER;
            end
        end
        PARITY: begin
            ns = STOP;
        end
        STOP: begin
            if(Data_Valid) begin
                ns = START;
            end
            else begin
                ns = IDLE;
            end
        end
        default: ns = IDLE;
        endcase
    end

    // output signals logic
    always @(*) begin
        mux_sel = STOP_BIT;
        busy_comb = 1'b0;
        ser_en = 1'b0;
        case (cs)
        IDLE: begin
        end
        START: begin
            mux_sel = START_BIT;
            busy_comb = 1'b1;
            // ser_en = 1'b1;
            ser_en = 1'b0;

        end
        DATA_TRANSFER: begin
            // if(ser_done && PAR_EN) begin
            //     mux_sel = PARITY_BIT; // pre-set parity for next cycle
            // end
            // else if(ser_done && !PAR_EN) begin
            //     mux_sel = STOP_BIT; // pre-set stop for next cycle
            // end
            // else begin
            //     mux_sel = DATA;
            // end
            // busy_comb = 1'b1;
            // ser_en = 1'b1;

            busy_comb = 1'b1;
            ser_en = 1'b1;
            mux_sel = DATA;
            if(ser_done)
			 ser_en = 1'b0 ;  
			else
 			 ser_en = 1'b1 ;   
        end
        PARITY: begin
            busy_comb = 1'b1;
            mux_sel = PARITY_BIT;
        end
        STOP: begin
            busy_comb = 1'b1;
            mux_sel = STOP_BIT;
        end
        default: begin
        end
        endcase
    end

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            busy <= 1'b0;
        end
        else begin
            busy <= busy_comb;
        end
    end
    
endmodule