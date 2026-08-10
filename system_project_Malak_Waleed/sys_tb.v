`timescale 1ns/1ps
module sys_tb;

    parameter REF_CLK_PERIOD = 2.0; // 20 ns period, 50 MHz ref clk freq
    parameter UART_CLK_PERIOD = 271.2; // 271.2 ns period, 3.6864 MHz uart clk freq
    parameter UART_TX_CLK_PERIOD = 8680.6; // 8680.6 ns period, 115.2 kHz TX uart clk freq

    parameter PARITY_ON = 1;
    parameter PARITY_TYP = 0;

    reg REF_CLK_tb;
    reg UART_CLK_tb;
    reg RST_tb;
    reg RX_IN_tb;
    wire TX_OUT_tb;
    wire Parity_Error_tb;
    wire Stop_Error_tb;

    // DUT instantiation
    SYS_TOP DUT(
        .REF_CLK(REF_CLK_tb),
        .UART_CLK(UART_CLK_tb),
        .RST_N(RST_tb),
        .UART_RX_IN(RX_IN_tb),
        .UART_TX_O(TX_OUT_tb),
        .parity_error(Parity_Error_tb),
        .framing_error(Stop_Error_tb)
    );

    // REF clock generation 
    always #(REF_CLK_PERIOD/2.0) REF_CLK_tb = ~REF_CLK_tb;
    // UART clock generation 
    always #(UART_CLK_PERIOD/2.0) UART_CLK_tb = ~UART_CLK_tb;

    // tb signals
    reg TX_CLK_tb;
    reg parity_bit_rx;

    reg start_bit; // signal to capture start bit
    reg [7:0] parallel_out; // bus to capture data bits converted to parallel
    reg partiy_bit_tx; // signal to capture parity bit
    reg stop_bit; // signal to capture stop bit
    reg expected_parity_tx; // signal to hold expected parity bit value

    // UART TX clock
    always #(UART_TX_CLK_PERIOD/2.0) TX_CLK_tb = ~TX_CLK_tb;

    initial begin
        $dumpfile("sys_dump.vcd");       
        $dumpvars;

        // inputs initialization
        initialize();
        // reset design
        reset();

        #(UART_CLK_PERIOD);

        // UART config 

        send_frame(8'haa); // write in RF cmd
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h02); // write REG2 address 
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h41); // write config values, prescaler = 16 and even parity
        #(2*UART_TX_CLK_PERIOD);

        $display("Testcase 1: Write 8'h2c in RF @ 8'h05");
        send_frame(8'haa); // write in RF cmd
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h05); // write address for write in RF cmd
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h2c); // write data for write in RF cmd
        #(2*UART_TX_CLK_PERIOD);

        $display("Testcase 2: Read from RF @ 8'h05");
        send_frame(8'hbb); // read from RF cmd
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h05); // write address for read from RF cmd
        #(5*UART_TX_CLK_PERIOD);

        capture_frame(8'h2c); // read data 
        $display("Testcase 2 Output = %0h", parallel_out);
        check_output(8'h2c);
        #(2*UART_TX_CLK_PERIOD);

        $display("Testcase 3: Add 5 + 6 = b");
        send_frame(8'hcc); // ALU operations with new operands cmd
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h05); // write operand A
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h06); // write operand B
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h00); // send ALU func
        #(5*UART_TX_CLK_PERIOD);

        capture_frame(8'h0b); // read ALU result 
        $display("Testcase 3 Output = %0h", parallel_out);
        check_output(8'h0b);
        #(2*UART_TX_CLK_PERIOD);

        $display("Testcase 4: NOR ~(5 | 6) = f8");
        send_frame(8'hdd); // ALU operations with saved operands cmd
        #(2*UART_TX_CLK_PERIOD);

        send_frame(8'h07); // send ALU func
        #(5*UART_TX_CLK_PERIOD);

        capture_frame(8'hf8); // read ALU result 
        $display("Testcase 4 Output = %0h", parallel_out);
        check_output(8'hf8);
        #(2*UART_TX_CLK_PERIOD);

        #(5*UART_TX_CLK_PERIOD);

        $stop;
    end

    task initialize;
        begin
            REF_CLK_tb = 0;
            UART_CLK_tb = 0;
            RX_IN_tb = 1;

            // tb signals
            TX_CLK_tb = 0;
            parity_bit_rx = 0;
            start_bit = 0;
            parallel_out = 0;
            partiy_bit_tx = 0;
            stop_bit = 0;
            expected_parity_tx = 0;
        end
    endtask

    task reset;
        begin
            RST_tb = 0;
            #(UART_CLK_PERIOD);
            RST_tb = 1;
            // sys is configured with even parity and 32 prescaler
        end
    endtask

    // task to send frame configured with even parity
    task send_frame;
        input [7:0] current_input;
        integer j;
        begin
            if(PARITY_ON) begin
                if(PARITY_TYP) begin
                    parity_bit_rx = ~(^(current_input));
                end
                else begin
                    parity_bit_rx = ^(current_input);
                end
            end
            RX_IN_tb = 0; // start bit
            #(UART_TX_CLK_PERIOD);
            for(j = 0; j < 8; j = j + 1) begin
                RX_IN_tb = current_input[j]; // data
                #(UART_TX_CLK_PERIOD);
            end
            RX_IN_tb = parity_bit_rx; // parity bit
            #(UART_TX_CLK_PERIOD);
            RX_IN_tb = 1; // stop bit
        end
    endtask

    // task to captue frame 
    task capture_frame;
        input [7:0] ref;
        integer i;
        begin
            // #(UART_TX_CLK_PERIOD);
            // capture start bit
            start_bit = TX_OUT_tb;

            // capture serial data and convert it to parallel
            for(i = 0; i < 8; i = i + 1) begin
                #(UART_TX_CLK_PERIOD);
                parallel_out[i] = TX_OUT_tb;
            end

            // capture parity bit and calculate expected
            partiy_bit_tx = TX_OUT_tb;

            if(PARITY_ON) begin
                if(PARITY_TYP) begin
                    parity_bit_rx = ~(^(ref));
                end
                else begin
                    parity_bit_rx = ^(ref);
                end
            end
            
            // capture stop bit
            #(UART_TX_CLK_PERIOD);
            stop_bit = TX_OUT_tb;
        end
    endtask

    // task to check output
    task check_output;
        input [7:0] ref;
        begin
            if(parallel_out == ref) begin
                $display("Testcase successed");
            end
            else begin
                $display("Testcase failed");
            end
        end
    endtask

    
endmodule