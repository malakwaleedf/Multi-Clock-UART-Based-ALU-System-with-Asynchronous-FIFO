module sys_top #(
    parameter REG_FILE_DEPTH = 16,
    parameter REG_FILE_WIDTH = 8,
    parameter REG_FILE_ADDR_SIZE = 4,
    parameter OPERAND_SIZE = REG_FILE_WIDTH,
    parameter ALU_FUNC_SIZE = 4,

    parameter FIFO_DATA_SIZE = REG_FILE_WIDTH,
    parameter FIFO_DEPTH = 16,
    parameter FIFO_ADDR_SIZE = 4,
    parameter FIFO_PTR_SIZE = 5
)(
    input REF_CLK,
    input UART_CLK,
    input RST,
    input RX_IN,
    output TX_OUT,
    output Parity_Error,
    output Stop_Error
);

    // Internal signals
    // synchronous reset signals
    wire RST_SYNC_REF; // Synchronized reset signal to REF_CLK domain
    wire RST_SYNC_UART; // Synchronized reset signal to UART_CLK domain

    // Register File signals
    wire [REG_FILE_WIDTH-1 : 0] TOP_WrData; // Data to be written to Register File
    wire [REG_FILE_ADDR_SIZE-1 : 0] TOP_Address; // Address to read/write Register File
    wire TOP_WrEn, TOP_RdEn; // Write and Read Enable signals for Register File
    wire [REG_FILE_WIDTH-1 : 0] TOP_RdData; // Data read from Register File
    wire TOP_RdData_Valid; // Data Valid signal for data read from Register File
    wire [REG_FILE_WIDTH-1 : 0] UART_CONFIG_REG; // UART Configuration Register
    wire [REG_FILE_WIDTH-1 : 0] TX_CLK_DIV_FACTOR; // Clock Division Factor Register

    // ALU signals
    wire [OPERAND_SIZE-1 : 0] OP_A, OP_B; // ALU Operands
    wire [ALU_FUNC_SIZE-1 : 0] TOP_ALU_FUN; // ALU Function select
    wire TOP_ALU_EN; // ALU Enable signal
    wire [OPERAND_SIZE-1 : 0] TOP_ALU_OUT; // ALU Output
    wire TOP_ALU_OUT_VALID; // ALU Output Valid signal

    // MUX signals 
    wire [REG_FILE_WIDTH-1 : 0] RX_CLK_DIV_FACTOR; // Clock Division Factor Register

    // CLK gating signals
    wire ALU_GATED_CLK; // Gated clock for ALU
    wire GATED_CLK_EN; // Enable signal for clock gating

    // CLK Divider signals
    wire TX_CLK; // Divided clock from UART_CLK for TX
    wire RX_CLK; // Divided clock from UART_CLK for RX
    wire CLK_DIV_EN;

    // FIFO signals
    wire [REG_FILE_WIDTH-1 : 0] FIFO_IN; // Data input to FIFO
    wire [REG_FILE_WIDTH-1 : 0] FIFO_OUT; // Data output from FIFO
    wire FIFO_OUT_VALID; // Data Valid signal for FIFO output
    wire FIFO_Wr_inc;
    wire FIFO_FULL;

    // Data Synchronizer signals
    wire [REG_FILE_WIDTH-1 : 0] DATA_SYNC_IN; // Assynchronized input to data synchronizer
    wire DATA_SYNC_IN_VALID; // Data Valid signal for synchronized input
    wire [REG_FILE_WIDTH-1 : 0] DATA_SYNC_OUT; // Synchronized output from data synchronizer
    wire DATA_SYNC_OUT_VALID; // Data Valid signal for synchronized output

    // Pulse Generator signals
    wire LVL_SIG; // Level signal input to pulse generator
    wire PULSE_SIG; // Pulse signal output from pulse generator

sys_ctrl #(
    .OPERAND_SIZE(OPERAND_SIZE),
    .RF_WIDTH(REG_FILE_WIDTH),
    .RF_ADDRESS(REG_FILE_ADDR_SIZE),
    .ALU_FUNC_SIZE(ALU_FUNC_SIZE)
) sys_ctrl_inst (
    .CLK(REF_CLK), // Clock Signal
    .RST(RST_SYNC_REF), // Active Low Reset
    .ALU_OUT(TOP_ALU_OUT), // ALU Output
    .OUT_Valid(TOP_ALU_OUT_VALID), // ALU Output Valid signal

    .ALU_FUN(TOP_ALU_FUN), // ALU Function select
    .EN(TOP_ALU_EN), // ALU Enable signal
    .CLK_EN(GATED_CLK_EN), // Clock Gating Enable signal
    .Address(TOP_Address), // Register File Address
    .WrEn(TOP_WrEn), // Register File Write Enable signal
    .RdEn(TOP_RdEn), // Register File Read Enable signal
    .WrData(TOP_WrData), // Register File Write Data Bus

    .RdData(TOP_RdData), // Register File Read Data Bus
    .RdData_Valid(TOP_RdData_Valid), // Register File Read Data Valid signal
    .RX_P_DATA(FIFO_OUT), // RX Parallel Data from UART
    .RX_D_VLD(FIFO_OUT_VALID), // RX Data Valid signal from UART
    .FIFO_FULL(FIFO_FULL),

    .TX_P_DATA(FIFO_IN), // TX Parallel Data to UART
    .TX_D_VLD(FIFO_Wr_inc), // TX Data Valid signal to UART
    .clk_div_en(CLK_DIV_EN) // Clock Divider Enable signal
);

register_file #(
    .DEPTH(REG_FILE_DEPTH),
    .WIDTH(REG_FILE_WIDTH),
    .ADDR_SIZE(REG_FILE_ADDR_SIZE)
) register_file_inst (
    .clk(REF_CLK),
    .rst(RST_SYNC_REF),
    .WrData(TOP_WrData),
    .Address(TOP_Address),
    .WrEn(TOP_WrEn),
    .RdEn(TOP_RdEn),
    .RdData(TOP_RdData),
    .RdData_Valid(TOP_RdData_Valid),
    .REG0(OP_A),
    .REG1(OP_B),
    .REG2(UART_CONFIG_REG),
    .REG3(TX_CLK_DIV_FACTOR)
);

alu #(
    .SIZE(OPERAND_SIZE)
) alu_inst (
    .A(OP_A),
    .B(OP_B),
    .ALU_FUN(TOP_ALU_FUN),
    .CLK(ALU_GATED_CLK),
    .EN(TOP_ALU_EN),
    .RST(RST_SYNC_REF),
    .ALU_OUT(TOP_ALU_OUT),
    .OUT_VALID(TOP_ALU_OUT_VALID)
);

clk_gate clk_gate_inst(
    .CLK(REF_CLK),
    .CLK_EN(GATED_CLK_EN),
    .GATED_CLK(ALU_GATED_CLK)
);

clk_divider clk_divider_inst_tx(
    .I_ref_clk(UART_CLK), // input reference frequency
    .I_rst_n(RST_SYNC_UART), // asynch activr low reset signal
    .I_clk_en(CLK_DIV_EN), // input clock divider block enable
    .I_div_ratio(TX_CLK_DIV_FACTOR), // input dividing ratio (integer value)
    .O_div_clk(TX_CLK) // output divided clock
);

mux4 mux4_inst(
    .select(UART_CONFIG_REG[7:2]),
    .MUX_OUT(RX_CLK_DIV_FACTOR)
);

clk_divider clk_divider_inst_rx(
    .I_ref_clk(UART_CLK), // input reference frequency
    .I_rst_n(RST_SYNC_UART), // asynch activr low reset signal
    .I_clk_en(CLK_DIV_EN), // input clock divider block enable
    .I_div_ratio(RX_CLK_DIV_FACTOR), // input dividing ratio (integer value)
    .O_div_clk(RX_CLK) // output divided clock
);

uart_top uart_top_inst(
    .TX_CLK(TX_CLK),  // UART TX Clock Signal
    .RX_CLK(RX_CLK), // UART RX Clock Signal
    .RST(RST_SYNC_UART), // Synchronized reset signal
    .PAR_TYP(UART_CONFIG_REG[1]), // Parity Type
    .PAR_EN(UART_CONFIG_REG[0]), // Parity_Enable
    .Prescaler(UART_CONFIG_REG[7:2]), // Oversampling Prescale

    .TX_IN_P(FIFO_OUT), // Input TX data byte (parallel)
    .TX_IN_V(FIFO_OUT_VALID), // Input TX data valid signal
    .TX_OUT_S(TX_OUT), // TX Frame Serial Out (serial)
    .TX_OUT_V(LVL_SIG), // TX Out Valid signal

    .RX_IN_S(RX_IN), // Input RX UART frame (serial)
    .RX_OUT_P(DATA_SYNC_IN), // RX Out Data (parallel)
    .RX_OUT_V(DATA_SYNC_IN_VALID), // RX Out Data Valid signal

    .Parity_Error(Parity_Error),
    .Stop_Error(Stop_Error)
);

pulse_gen pulse_gen_inst (
    .CLK(UART_CLK),
    .RST(RST_SYNC_UART),
    .LVL_SIG(LVL_SIG),
    .PULSE_SIG(PULSE_SIG) // input to FIFO
);

rst_sync rst_sync_inst_REF(
    .RST(RST), // input asynch rest
    .CLK(REF_CLK), // design clock
    .SYNC_RST(RST_SYNC_REF) // output synch reset (asynch assertion, synch deassertion)
);

rst_sync rst_sync_inst_UART(
    .RST(RST), // input asynch rest
    .CLK(UART_CLK), // design clock
    .SYNC_RST(RST_SYNC_UART) // output synch reset (asynch assertion, synch deassertion)
);

data_sync #( 
    .BUS_WIDTH(REG_FILE_WIDTH) // Width of synchronized bus
) data_sync_inst (
    .Unsync_bus(DATA_SYNC_IN), // Unsynchronized data bus
    .bus_enable(DATA_SYNC_IN_VALID), // Source domain enable signal
    .CLK(REF_CLK), // Destination domain clock
    .RST(RST_SYNC_REF), // Destination domain Active Low Asynchronous Reset
    .sync_bus(DATA_SYNC_OUT), // Synchronized data bus
    .enable_pulse(DATA_SYNC_OUT_VALID) // Destination domain enable signal
);

Async_fifo #(
    .D_SIZE(FIFO_DATA_SIZE), // data size
    .A_SIZE(FIFO_ADDR_SIZE), // address size
    .P_SIZE(FIFO_PTR_SIZE), // pointer width
    .F_DEPTH(FIFO_DEPTH) // fifo depth
) Async_fifo_inst (
   .i_w_clk(REF_CLK), // write domian operating clock
   .i_w_rstn(RST_SYNC_REF), // write domian active low reset  
   .i_w_inc(FIFO_Wr_inc), // write control signal 
   .i_r_clk(UART_CLK), // read domian operating clock
   .i_r_rstn(RST_SYNC_UART), // read domian active low reset 
   .i_r_inc(PULSE_SIG), // read control signal
   .i_w_data(FIFO_IN), // write data bus 
   .o_r_data(FIFO_OUT), // read data bus
   .o_full(FIFO_FULL), // fifo full flag
   .o_empty(FIFO_OUT_VALID) // fifo empty flag
);
    
endmodule