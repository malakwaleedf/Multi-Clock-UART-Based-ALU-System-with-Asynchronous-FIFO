module data_sampling (
    input RX_IN, // input design serial in data
    input [5:0] Prescaler, // input bus to configure the prescaler value 
    input CLK, // design clock
    input RST, // asynch reset
    input [4:0] edge_cnt, // input bus holding the current number of edges per bit
    input dat_samp_en, // input signal to enable the module 
    output reg sampled_bit, // output signal holding the value of the sampled bit
    output reg sampled_bit_ready // output signal to indicate that the sampled bit is ready
);

    // prescaler values
    localparam prescaler_8 = 6'b00_1000;
    localparam prescaler_16 = 6'b01_0000;
    localparam prescaler_32 = 6'b10_0000;

    // sampling edge numbers when prescaler = 8
    localparam prescaler_8_mid = 5'b0_0100; // edge_cnt = 4
    localparam prescaler_8_pre_mid = 5'b0_0011; // edge_cnt = 3
    localparam prescaler_8_post_mid = 5'b0_0101; // edge_cnt = 5

    // sampling edge numbers when prescaler = 16
    localparam prescaler_16_mid = 5'b0_1000; // edge_cnt = 8
    localparam prescaler_16_pre_mid = 5'b0_0111; // edge_cnt = 7
    localparam prescaler_16_post_mid = 5'b0_1001; // edge_cnt = 9

    // sampling edge numbers when prescaler = 32
    localparam prescaler_32_mid = 5'b1_0000; // edge_cnt = 16
    localparam prescaler_32_pre_mid = 5'b0_1111; // edge_cnt = 15
    localparam prescaler_32_post_mid = 5'b1_0001; // edge_cnt = 17

    reg sampled_bit_mid; // internal signal to hold the bit sampled at the middle 
    reg sampled_bit_pre_mid; // internal signal to hold the bit sampled at before the middle by 1 clk
    reg sampled_bit_post_mid; // internal signal to hold the bit sampled at after the middle by 1 clk

    // registered sampled_bit
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            sampled_bit <= 1'b0;
            sampled_bit_ready <= 1'b0;
        end
        else if(dat_samp_en) begin
            if(edge_cnt == (Prescaler - 1'b1)) begin
                if(sampled_bit_mid == sampled_bit_pre_mid && sampled_bit_mid == sampled_bit_post_mid) begin
                    sampled_bit <= sampled_bit_mid;
                end
                else begin
                    sampled_bit <= ~(sampled_bit_mid ^ (sampled_bit_pre_mid ^ sampled_bit_post_mid));
                end
                sampled_bit_ready <= 1'b1;
            end
            else begin
                sampled_bit_ready <= 1'b0;
            end
        end
    end

    // serial data sampling 
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            sampled_bit_pre_mid <= 1'b0;
            sampled_bit_mid <= 1'b0;
            sampled_bit_post_mid <= 1'b0;
        end
        else if(dat_samp_en) begin
            case (Prescaler)
            prescaler_8: begin
                case (edge_cnt)
                prescaler_8_pre_mid: sampled_bit_pre_mid <= RX_IN;
                prescaler_8_mid: sampled_bit_mid <= RX_IN;
                prescaler_8_post_mid: sampled_bit_post_mid <= RX_IN;
                endcase
            end
            prescaler_16: begin
                case (edge_cnt)
                prescaler_16_pre_mid: sampled_bit_pre_mid <= RX_IN;
                prescaler_16_mid: sampled_bit_mid <= RX_IN;
                prescaler_16_post_mid: sampled_bit_post_mid <= RX_IN;
                endcase
            end
            prescaler_32: begin
                case (edge_cnt)
                prescaler_32_pre_mid: sampled_bit_pre_mid <= RX_IN;
                prescaler_32_mid: sampled_bit_mid <= RX_IN;
                prescaler_32_post_mid: sampled_bit_post_mid <= RX_IN;
                endcase
            end
            endcase
        end
    end
    
endmodule