module register_file #(
    parameter DEPTH = 16,
    parameter WIDTH = 8,
    parameter ADDR_SIZE = 4
)(
    input clk,
    input rst,
    input [WIDTH-1 : 0] WrData,
    input [ADDR_SIZE-1 : 0] Address,
    input WrEn,
    input RdEn,
    output reg [WIDTH-1 : 0]  RdData,
    output reg RdData_Valid,
    output reg [WIDTH-1 : 0] REG0, // ALU Operand A
    output reg [WIDTH-1 : 0] REG1, // ALU Operand B
    output reg [WIDTH-1 : 0] REG2, // UART Config, REG2[0] = parity enable, REG2[1] = parity type, REG2[7:2] = prescale
    output reg [WIDTH-1 : 0] REG3 // Div Ratio
);

    reg [WIDTH-1 : 0] reg_file [0 : DEPTH-1];

    integer i;

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            RdData_Valid <= 1'b0;

            reg_file[0] <= 'b0;
            reg_file[1] <= 'b0;
            reg_file[2] <= {'d32, 1'd0, 1'd1}; // default value, parity enable, parity type, prescale
            reg_file[3] <= 'd32; // default value, division ratio

            for(i=4; i<DEPTH; i=i+1) begin
                reg_file[i] <= 'b0;
            end
            
            RdData <= 'b0;
        end
        else if(WrEn && !RdEn) begin
            reg_file[Address] <= WrData;
        end
        else if(RdEn && !WrEn) begin
            RdData <= reg_file[Address];
            RdData_Valid <= 1'b1;
        end
        else if(!RdEn) begin
            RdData_Valid <= 1'b0;
        end
    end

    // config registers
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            REG0 <= 'b0;
            REG1 <= 'b0;
            REG2[0] <= 1'b1; // default value, parity enable 
            REG2[1] <= 1'b0; // default value, parity type
            REG2[WIDTH-1 : 2] <= 'd32; // default value, prescale
            REG3 <= 'd32; // default value, division ratio
        end
        else begin
            REG0 <= reg_file[0];
            REG1 <= reg_file[1];
            REG2 <= reg_file[2];
            REG3 <= reg_file[3];
        end
    end
    
endmodule