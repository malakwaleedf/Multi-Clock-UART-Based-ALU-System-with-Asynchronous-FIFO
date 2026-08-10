module alu #(
    parameter SIZE = 16
)(
    input [SIZE-1 : 0] A, B,  // ALU operands
    input [3:0] ALU_FUN,  // ALU operation choice
    input CLK,  // design clock
    input EN,
    input RST,
    output reg [SIZE-1 : 0] ALU_OUT,  // ALU result
    output reg OUT_VALID
);

    reg [SIZE-1 : 0] comb_out;
    reg comb_out_valid;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            ALU_OUT <= 'b0;
            OUT_VALID <= 1'b0;
        end
        else begin
            ALU_OUT <= comb_out;
            OUT_VALID <= comb_out_valid;
        end
    end

    always @(*) begin
        comb_out = 'b0;
        comb_out_valid = 1'b0;
        if(EN) begin
            comb_out_valid = 1'b1;
            case (ALU_FUN)
            4'b0000: begin // add function
                comb_out = A + B;
            end
            4'b0001: begin // subtract function
                comb_out = A - B;
            end
            4'b0010: begin // multiply function
                comb_out = A * B;
            end
            4'b0011: begin // divide function
                comb_out = A / B;
            end
            4'b0100: begin // AND function
                comb_out = A & B;
            end
            4'b0101: begin // OR function
                comb_out = A | B;
            end
            4'b0110: begin // NAND function
                comb_out = ~(A & B);
            end
            4'b0111: begin // NOR function
                comb_out = ~(A | B);
            end
            4'b1000: begin // XOR function
                comb_out = A ^ B;
            end
            4'b1001: begin // XNOR function
                comb_out = ~(A ^ B);
            end
            4'b1010: begin // equal function
                comb_out = (A == B)? 1 : 0;
            end
            4'b1011: begin // greater than function
                comb_out = (A > B)? 2 : 0;
            end
            4'b1100: begin // smaller than function
                comb_out = (A < B)? 3 : 0;
            end
            4'b1101: begin // shift right function
                comb_out = A >> 1;
            end
            4'b1110: begin // shift left function
                comb_out = A << 1;
            end
            default: begin // default
                comb_out = 16'b0;
            end
            endcase
        end
        else begin
           comb_out = 'b0;
            comb_out_valid = 1'b0;
        end
    end

endmodule