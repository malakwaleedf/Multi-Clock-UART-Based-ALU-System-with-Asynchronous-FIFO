module fifo_memory #(
    parameter DATA_WIDTH = 32, // Data width
    parameter FIFO_DEPTH = 32, // FIFO depth
    parameter ADDR_WIDTH = 5 // Address width
) (
    input wire clk_write, // Write clock
    input wire rst_write, // Write domain reset signal
    input wire write_en, // Write enable signal
    input wire [ADDR_WIDTH-1:0] write_addr, // Write address
    input wire [DATA_WIDTH-1:0] data_in, // Data input  

    input wire clk_read, // Read clock
    input wire rst_read, // Read domain reset signal
    input wire read_en, // Read enable signal
    input wire [ADDR_WIDTH-1:0] read_addr, // Read address
    output reg [DATA_WIDTH-1:0] data_out, // Data output

    input wire full // FIFO full flag
);

// Memory array to store FIFO data
reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

// Write operation
always @(posedge clk_write or negedge rst_write) begin
    if (!rst_write) begin
        
    end else if (write_en && !full) begin
        fifo_mem[write_addr] <= data_in; // Write data to FIFO memory if write is enabled and FIFO is not full
    end   
end

// Read operation
always @(posedge clk_read or negedge rst_read) begin
    if (!rst_read) begin
        data_out <= 0; // Reset data output to 0 on reset
    end else if (read_en) begin
        data_out <= fifo_mem[read_addr]; // Read data from FIFO memory if read is enabled and FIFO is not empty 
    end   
end

// assign data_out = fifo_mem[read_addr]; // Read data from FIFO memory

endmodule