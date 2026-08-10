/*
    At write domain
    Write clock frequency is 20MHz
    This module outputs gray encoded write pointer, write address
    and computes the full flag
*/

module fifo_write #(
    parameter ADDR_WIDTH = 5, // Address width
    parameter POINTER_WIDTH = 6 // Pointer width
) (
    input wire clk_write, // Write clock
    input wire rst_write, // Write domain reset signal
    input wire write_en, // Write enable signal
    input wire [POINTER_WIDTH-1:0] read_ptr_grey, // Read pointer in grey code synchronized to write clock

    output wire [ADDR_WIDTH-1:0] write_addr, // Write address
    output reg [POINTER_WIDTH-1:0] write_ptr_grey, // Write pointer in grey code
    output wire full // FIFO full flag
);

reg [POINTER_WIDTH-1:0] write_ptr_bin; // Write pointer before grey encoding
wire [POINTER_WIDTH-1:0] write_ptr_grey_comb; // Write pointer in grey code (combinational)

assign write_ptr_grey_comb = write_ptr_bin ^ (write_ptr_bin >> 1); // Applying grey encoding to write pointer

// Write pointer before grey encoding logic
always @(posedge clk_write or negedge rst_write) begin
    if(!rst_write) begin
        write_ptr_bin <= 'd0;
    end
    else if(write_en && !full) begin
        write_ptr_bin <= write_ptr_bin + 1; // Increment write pointer if write is enabled and FIFO is not full
    end
end

assign write_addr = write_ptr_bin[ADDR_WIDTH-1:0];  // Write address is the lower ADDR_WIDTH bits of the write pointer

// Register grey encoded write pointer
always @(posedge clk_write or negedge rst_write) begin 
    if(!rst_write) begin
        write_ptr_grey <= 'd0;
    end 
    else begin
        write_ptr_grey <= write_ptr_grey_comb;
    end
end

assign full = (write_ptr_grey_comb == {~read_ptr_grey[POINTER_WIDTH-1], ~read_ptr_grey[POINTER_WIDTH-2], read_ptr_grey[POINTER_WIDTH-3:0]}); // FIFO is full when write pointer equals read pointer with 2 MSB inverted

endmodule