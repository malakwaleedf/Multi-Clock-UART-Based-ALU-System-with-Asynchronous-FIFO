
module SYS_TOP # ( parameter DATA_WIDTH = 8 ,  RF_ADDR = 4 , NUM_OF_CHAINS = 3)

(
 input   wire                          scan_clk,
 input   wire                          scan_rst,
 input   wire                          test_mode,
 input   wire                          SE,
 input   wire  [NUM_OF_CHAINS-1 : 0]   SI,
 output   wire  [NUM_OF_CHAINS-1 : 0]   SO,

 input   wire                          RST_N,
 input   wire                          UART_CLK,
 input   wire                          REF_CLK,
 input   wire                          UART_RX_IN,
 output  wire                          UART_TX_O,
 output  wire                          parity_error,
 output  wire                          framing_error
);


wire                                   SYNC_UART_RST,
                                       SYNC_REF_RST;
									   
wire					               UART_TX_CLK;
wire					               UART_RX_CLK;


wire      [DATA_WIDTH-1:0]             Operand_A,
                                       Operand_B,
									   UART_Config,
									   DIV_RATIO;
									   
wire      [DATA_WIDTH-1:0]             DIV_RATIO_RX;
									   
wire      [DATA_WIDTH-1:0]             UART_RX_OUT;
wire         						   UART_RX_V_OUT;
wire      [DATA_WIDTH-1:0]			   UART_RX_SYNC;
wire                                   UART_RX_V_SYNC;

wire      [DATA_WIDTH-1:0]             UART_TX_IN;
wire        						   UART_TX_VLD;
wire      [DATA_WIDTH-1:0]             UART_TX_SYNC;
wire        						   UART_TX_V_SYNC;

wire                                   UART_TX_Busy;	
wire                                   UART_TX_Busy_PULSE;	
									   
wire                                   RF_WrEn;
wire                                   RF_RdEn;
wire      [RF_ADDR-1:0]                RF_Address;
wire      [DATA_WIDTH-1:0]             RF_WrData;
wire      [DATA_WIDTH-1:0]             RF_RdData;
wire                                   RF_RdData_VLD;									   

wire                                   CLKG_EN;
wire                                   ALU_EN;
wire      [3:0]                        ALU_FUN; 
wire      [DATA_WIDTH*2-1:0]           ALU_OUT;
wire                                   ALU_OUT_VLD; 
									   
wire                                   ALU_CLK ;								   

wire                                   FIFO_FULL ;
	
wire                                   CLKDIV_EN ;


wire                     CLK_M_REF;
wire                     CLK_M_UART;
wire                     CLK_M_UART_TX;
wire                     CLK_M_UART_RX;
wire                     RST_M;

mux2X1  mux_clk_ref(
	.IN_0(REF_CLK),
	.IN_1(scan_clk),
	.SEL(test_mode), 
	.OUT(CLK_M_REF) 
);

mux2X1  mux_clk_uart(
	.IN_0(UART_CLK),
	.IN_1(scan_clk),
	.SEL(test_mode), 
	.OUT(CLK_M_UART) 
);

mux2X1  mux_clk_uart_tx(
	.IN_0(UART_TX_CLK),
	.IN_1(scan_clk),
	.SEL(test_mode), 
	.OUT(CLK_M_UART_TX) 
);

mux2X1  mux_clk_uart_rx(
	.IN_0(UART_RX_CLK),
	.IN_1(scan_clk),
	.SEL(test_mode), 
	.OUT(CLK_M_UART_RX) 
);

mux2X1  mux_rst(
	.IN_0(RST_N),
	.IN_1(scan_rst),
	.SEL(test_mode), 
	.OUT(RST_M) 
);

mux2X1  mux_rst_ref(
	.IN_0(SYNC_REF_RST),
	.IN_1(scan_rst),
	.SEL(test_mode), 
	.OUT(RST_M) 
);

mux2X1  mux_rst_uart(
	.IN_0(SYNC_UART_RST),
	.IN_1(scan_rst),
	.SEL(test_mode), 
	.OUT(RST_M) 
);
								   
///********************************************************///
//////////////////// Reset synchronizers /////////////////////
///********************************************************///

RST_SYNC # (.NUM_STAGES(2)) U0_RST_SYNC (
.RST(RST_M),
.CLK(CLK_M_UART),
.SYNC_RST(SYNC_UART_RST)
);

RST_SYNC # (.NUM_STAGES(2)) U1_RST_SYNC (
.RST(RST_M),
.CLK(CLK_M_REF),
.SYNC_RST(SYNC_REF_RST)
);

///********************************************************///
////////////////////// Data Synchronizer /////////////////////
///********************************************************///

DATA_SYNC # (.NUM_STAGES(2) , .BUS_WIDTH(8)) U0_ref_sync (
.CLK(CLK_M_REF),
.RST(RST_M),
.unsync_bus(UART_RX_OUT),
.bus_enable(UART_RX_V_OUT),
.sync_bus(UART_RX_SYNC),
.enable_pulse_d(UART_RX_V_SYNC)
);

///********************************************************///
///////////////////////// Async FIFO /////////////////////////
///********************************************************///

Async_fifo #(.D_SIZE(DATA_WIDTH) , .P_SIZE(4)  , .F_DEPTH(8)) U0_UART_FIFO (
.i_w_clk(CLK_M_REF),
.i_w_rstn(RST_M),  
.i_w_inc(UART_TX_VLD),
.i_w_data(UART_TX_IN),             
.i_r_clk(CLK_M_UART_TX),              
.i_r_rstn(RST_M),              
.i_r_inc(UART_TX_Busy_PULSE),              
.o_r_data(UART_TX_SYNC),             
.o_full(FIFO_FULL),               
.o_empty(UART_TX_V_SYNC)               
);

///********************************************************///
//////////////////////// Pulse Generator /////////////////////
///********************************************************///

PULSE_GEN U0_PULSE_GEN (
.clk(CLK_M_UART_TX),
.rst(RST_M),
.lvl_sig(UART_TX_Busy),
.pulse_sig(UART_TX_Busy_PULSE)
);

///********************************************************///
//////////// Clock Divider for UART_TX Clock /////////////////
///********************************************************///

ClkDiv U0_ClkDiv (
.i_ref_clk(CLK_M_UART),             
.i_rst(RST_M),                 
.i_clk_en(CLKDIV_EN),               
.i_div_ratio(DIV_RATIO),           
.o_div_clk(UART_TX_CLK)             
);

///********************************************************///
/////////////////////// Custom Mux Clock /////////////////////
///********************************************************///

CLKDIV_MUX U0_CLKDIV_MUX (
.IN(UART_Config[7:2]),
.OUT(DIV_RATIO_RX)
);

///********************************************************///
//////////// Clock Divider for UART_RX Clock /////////////////
///********************************************************///

ClkDiv U1_ClkDiv (
.i_ref_clk(CLK_M_UART),             
.i_rst(RST_M),                 
.i_clk_en(CLKDIV_EN),               
.i_div_ratio(DIV_RATIO_RX),           
.o_div_clk(UART_RX_CLK)             
);

///********************************************************///
/////////////////////////// UART /////////////////////////////
///********************************************************///

UART  U0_UART (
.RST(RST_M),
.TX_CLK(CLK_M_UART_TX),
.RX_CLK(CLK_M_UART_RX),
.parity_enable(UART_Config[0]),
.parity_type(UART_Config[1]),
.Prescale(UART_Config[7:2]),
.RX_IN_S(UART_RX_IN),
.RX_OUT_P(UART_RX_OUT),                      
.RX_OUT_V(UART_RX_V_OUT),                      
.TX_IN_P(UART_TX_SYNC), 
.TX_IN_V(!UART_TX_V_SYNC), 
.TX_OUT_S(UART_TX_O),
.TX_OUT_V(UART_TX_Busy),
.parity_error(parity_error),
.framing_error(framing_error)                  
);

///********************************************************///
//////////////////// System Controller ///////////////////////
///********************************************************///

sys_ctrl U0_SYS_CTRL (
.CLK(CLK_M_REF),
.RST(RST_M),
.RF_RdData(RF_RdData),
.RF_RdData_VLD(RF_RdData_VLD),
.RF_WrEn(RF_WrEn),
.RF_RdEn(RF_RdEn),
.RF_Address(RF_Address),
.RF_WrData(RF_WrData),
.ALU_EN(ALU_EN),
.ALU_FUN(ALU_FUN), 
.ALU_OUT(ALU_OUT),
.ALU_OUT_VLD(ALU_OUT_VLD),  
.CLKG_EN(CLKG_EN), 
.CLKDIV_EN(CLKDIV_EN),   
.FIFO_FULL(FIFO_FULL),
.UART_RX_SYNC(UART_RX_SYNC), 
.UART_RX_V_SYNC(UART_RX_V_SYNC),
.UART_TX_IN(UART_TX_IN), 
.UART_TX_VLD(UART_TX_VLD)
);

///********************************************************///
/////////////////////// Register File ////////////////////////
///********************************************************///

RegFile U0_RegFile (
.CLK(CLK_M_REF),
.RST(RST_M),
.WrEn(RF_WrEn),
.RdEn(RF_RdEn),
.Address(RF_Address),
.WrData(RF_WrData),
.RdData(RF_RdData),
.RdData_VLD(RF_RdData_VLD),
.REG0(Operand_A),
.REG1(Operand_B),
.REG2(UART_Config),
.REG3(DIV_RATIO)
);

///********************************************************///
//////////////////////////// ALU /////////////////////////////
///********************************************************///
 
ALU U0_ALU (
.CLK(ALU_CLK),
.RST(RST_M),  
.A(Operand_A), 
.B(Operand_B),
.EN(ALU_EN),
.ALU_FUN(ALU_FUN),
.ALU_OUT(ALU_OUT),
.OUT_VALID(ALU_OUT_VLD)
);

///********************************************************///
///////////////////////// Clock Gating ///////////////////////
///********************************************************///

CLK_GATE U0_CLK_GATE (
.test_en(test_mode),
.CLK_EN(CLKG_EN),
.CLK(CLK_M_REF),
.GATED_CLK(ALU_CLK)
);


endmodule
 
