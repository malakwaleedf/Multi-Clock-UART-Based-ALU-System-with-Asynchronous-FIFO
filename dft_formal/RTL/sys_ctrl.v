module sys_ctrl #(
    parameter OPERAND_SIZE = 8,
    parameter RF_WIDTH = OPERAND_SIZE,
    parameter RF_ADDRESS_SIZE = 4,
    parameter ALU_FUNC_SIZE = 4
) (
    input CLK, // Clock Signal
    input RST, // Active Low Reset
    input [(OPERAND_SIZE*2)-1 : 0] ALU_OUT, // ALU Output
    input ALU_OUT_VLD, // ALU Output Valid signal

    output reg [ALU_FUNC_SIZE-1 : 0] ALU_FUN, // ALU Function select
    output reg ALU_EN, // ALU Enable signal
    output reg CLKG_EN, // Clock Gating Enable signal
    output reg [RF_ADDRESS_SIZE-1 : 0] RF_Address, // Register File Address
    output reg RF_WrEn, // Register File Write Enable signal
    output reg RF_RdEn, // Register File Read Enable signal
    output reg [RF_WIDTH-1 : 0] RF_WrData, // Register File Write Data Bus

    input [RF_WIDTH-1 : 0] RF_RdData, // Register File Read Data Bus
    input RF_RdData_VLD, // Register File Read Data Valid signal
    input [RF_WIDTH-1 : 0] UART_RX_SYNC, // RX Parallel Data from UART
    input UART_RX_V_SYNC, // RX Data Valid signal from UART
    input FIFO_FULL,

    output reg [RF_WIDTH-1 : 0] UART_TX_IN, // TX Parallel Data to UART
    output reg UART_TX_VLD, // TX Data Valid signal to UART
    output reg CLKDIV_EN // Clock Divider Enable signal
);

    localparam IDLE = 4'b0000; // 0

    localparam RF_READ_ADDR_Wr = 4'b0001; // 1
    localparam RF_WRITE_DATA = 4'b0011; // 3

    localparam RF_READ_ADDR_Rd = 4'b0010; // 2
    localparam RF_READ_DATA = 4'b0110; // 6
    localparam RF_TX_WRITE = 4'b0111; // 7

    localparam RF_WRITE_A = 4'b0101; // 5
    localparam RF_WRITE_B = 4'b0100; // 4
    
    localparam ALU_ON = 4'b1100; // c

    localparam ALU_TX_WRITE = 4'b1101; // d

    reg [3:0] cs, ns;

    reg [RF_ADDRESS_SIZE-1 : 0] Address_comb;
    reg [RF_ADDRESS_SIZE-1 : 0] Address_reg;
    reg address_update_en;

    localparam OP_A_ADDR = 8'h00;
    localparam OP_B_ADDR = 8'h01;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            cs <= 4'b0;
        end
        else begin
            cs <= ns;
        end
    end

    always @(*) begin
        case (cs)
        IDLE: begin
            if(UART_RX_V_SYNC) begin

                case (UART_RX_SYNC)
                8'haa: ns = RF_READ_ADDR_Wr;
                8'hbb: ns = RF_READ_ADDR_Rd;
                8'hcc: ns = RF_WRITE_A;
                8'hdd: ns = ALU_ON;
                default: ns = IDLE;
                endcase

            end
            else begin
                ns = IDLE;
            end
        end

        RF_READ_ADDR_Wr: begin
            if(UART_RX_V_SYNC) begin
                ns = RF_WRITE_DATA;
            end
            else begin
                ns = RF_READ_ADDR_Wr;
            end
        end
        RF_WRITE_DATA: begin
            if(UART_RX_V_SYNC) begin
                ns = IDLE;
            end
            else begin
                ns = RF_WRITE_DATA;
            end
        end

        RF_READ_ADDR_Rd: begin
            if(UART_RX_V_SYNC) begin
                ns = RF_READ_DATA;
            end
            else begin
                ns = RF_READ_ADDR_Rd;
            end
        end

        RF_READ_DATA: begin
            if(RF_RdData_VLD && !FIFO_FULL) begin
                ns = RF_TX_WRITE;
            end
            else begin
                ns = RF_READ_DATA;
            end
        end

        RF_TX_WRITE: begin
            ns = IDLE;
        end

        RF_WRITE_A: begin
            if(UART_RX_V_SYNC) begin
                ns = RF_WRITE_B;
            end
            else begin
                ns = RF_WRITE_A;
            end
        end
        RF_WRITE_B: begin
            if(UART_RX_V_SYNC) begin
                ns = ALU_ON;
            end
            else begin
                ns = RF_WRITE_B;
            end
        end

        ALU_ON: begin
            if(ALU_OUT_VLD && !FIFO_FULL) begin
                ns = ALU_TX_WRITE;
            end
            else begin
                ns = ALU_ON;
            end
        end

        ALU_TX_WRITE: begin
            ns = IDLE;
        end

        default: ns = IDLE;
        endcase
    end

    always @(*) begin
        // ALU signals
        ALU_EN = 1'b0;
        CLKG_EN = 1'b0;
        ALU_FUN = 'b0;

        // Register File signals
        RF_WrEn = 1'b0;
        RF_RdEn = 1'b0;
        RF_Address = 'b0;
        Address_comb = 'b0;
        address_update_en = 1'b0;
        RF_WrData = 'b0;
        
        // UART TX signals
        UART_TX_IN = 'b0;
        UART_TX_VLD = 1'b0;

        // Clock Divider signal
        CLKDIV_EN = 1'b1; // always on 

        case (cs)
        IDLE: begin
            // default values
        end 

        RF_READ_ADDR_Wr: begin
            if(UART_RX_V_SYNC) begin
                RF_Address = UART_RX_SYNC;
                address_update_en = 1'b1;
                Address_comb = UART_RX_SYNC;
            end
        end
        RF_WRITE_DATA: begin
            if(UART_RX_V_SYNC) begin
                RF_Address = Address_reg;
                RF_WrEn = 1'b1;
                RF_WrData = UART_RX_SYNC;
            end
        end

        RF_READ_ADDR_Rd: begin
            if(UART_RX_V_SYNC) begin
                RF_Address = UART_RX_SYNC;
                address_update_en = 1'b1;
                Address_comb = UART_RX_SYNC;
            end
        end
        RF_READ_DATA: begin
            RF_Address = Address_reg;
            RF_RdEn = 1'b1;
        end

        RF_TX_WRITE: begin
            UART_TX_IN = RF_RdData;
            UART_TX_VLD = 1'b1;
        end 

        RF_WRITE_A: begin
            if(UART_RX_V_SYNC) begin
                RF_Address = OP_A_ADDR;
                RF_WrEn = 1'b1;
                RF_WrData = UART_RX_SYNC;
            end
        end
        RF_WRITE_B: begin
            if(UART_RX_V_SYNC) begin
                RF_Address = OP_B_ADDR;
                RF_WrEn = 1'b1;
                RF_WrData = UART_RX_SYNC;
            end
        end

        ALU_ON: begin
            if(UART_RX_V_SYNC) begin
                ALU_EN = 1'b1;
                CLKG_EN = 1'b1;
                ALU_FUN = UART_RX_SYNC;
            end
        end

        ALU_TX_WRITE: begin
            CLKG_EN = 1'b1;
            UART_TX_IN = ALU_OUT;
            UART_TX_VLD = 1'b1;
        end  

        default: begin
            // default values
        end 
        endcase
    end
    

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            Address_reg <= 'b0;
        end
        else begin
            if(address_update_en) begin
                Address_reg <= Address_comb;
            end
        end
    end

endmodule