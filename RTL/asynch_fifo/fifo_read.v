/*
    At read domain
    Read clock frequency is 100MHz
    This module outputs gray encoded read pointer, read address
    and computes the empty flag
*/

module fifo_read #(
    parameter ADDR_WIDTH = 5, // Address width
    parameter POINTER_WIDTH = 6 // Pointer width
) (
    input wire clk_read, // Read clock
    input wire rst_read, // Read domain reset signal
    input wire read_en, // Read enable signal 
    input wire [POINTER_WIDTH-1:0] write_ptr_grey, // Write pointer in grey code synchronized to read clock

    output wire [ADDR_WIDTH-1:0] read_addr, // Read address
    output reg [POINTER_WIDTH-1:0] read_ptr_grey, // Read pointer in grey code
    output wire empty // FIFO empty flag
);

reg [POINTER_WIDTH-1:0] read_ptr_bin; // Read pointer before grey encoding
wire [POINTER_WIDTH-1:0] read_ptr_grey_comb; // Read pointer in grey code (combinational)

assign read_ptr_grey_comb = read_ptr_bin ^ (read_ptr_bin >> 1); // Applying grey encoding to read pointer

// Read pointer before grey encoding logic
always @(posedge clk_read or negedge rst_read) begin
    if(!rst_read) begin
        read_ptr_bin <= 'd0;
    end
    else if(read_en && !empty) begin
        read_ptr_bin <= read_ptr_bin + 1; // Increment read pointer if read is enabled and FIFO is not empty
    end
end

assign read_addr = read_ptr_bin[ADDR_WIDTH-1:0];  // Read address is the lower ADDR_WIDTH bits of the read pointer

// Register grey encoded read pointer
always @(posedge clk_read or negedge rst_read) begin
    if(!rst_read) begin
        read_ptr_grey <= 'd0;
    end 
    else begin
        read_ptr_grey <= read_ptr_grey_comb;
    end
end

assign empty = (read_ptr_grey_comb == write_ptr_grey); // FIFO is empty when read pointer equals write pointer
    
endmodule