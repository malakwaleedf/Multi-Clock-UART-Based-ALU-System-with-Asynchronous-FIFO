/*
    Asynchronous FIFO Module
    Used to allow data to be written and read at different clock domains, 
    ensuring data integrity and synchronization.

    It includes:
    fifo_memory: memory block to store data
    synchronizer: used to synchronize the read and write pointers across clock domains.
    fifo_write: logic to manage write address, write pointer and full flag generation
    fifo_read: logic to manage read address, read pointer and empty flag generation
 */
module asynch_fifo #(
    parameter DATA_WIDTH = 32, // Data width
    parameter FIFO_DEPTH = 32, // FIFO depth
    parameter ADDR_WIDTH = 5, // Address width 
    parameter POINTER_WIDTH = 6 // Pointer width
) (
    // Write domain signals
    input wire clk_write, // Write clock
    input wire rst_write, // Write domain reset signal
    input wire write_en, // Write enable signal
    input wire [DATA_WIDTH-1:0] data_in, // Data input  

    // Read domain signals
    input wire clk_read, // Read clock
    input wire rst_read, // Read domain reset signal
    input wire read_en, // Read enable signal
    output wire [DATA_WIDTH-1:0] data_out, // Data output

    output wire full, // FIFO full flag
    output wire empty // FIFO empty flag
);

wire [ADDR_WIDTH-1:0] write_addr; // Write address 
wire [ADDR_WIDTH-1:0] read_addr; // Read address 
wire [POINTER_WIDTH-1:0] write_ptr_grey; // Write pointer in grey code
wire [POINTER_WIDTH-1:0] synch_read_ptr_grey; // Read pointer in grey code synchronized to write clock
wire [POINTER_WIDTH-1:0] read_ptr_grey; // Read pointer in grey code
wire [POINTER_WIDTH-1:0] synch_write_ptr_grey; // Write pointer in grey code synchronized to read clock

// FIFO memory instantiation
fifo_memory #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) fifo_memory_inst(
    .clk_write(clk_write),
    .rst_write(rst_write),
    .write_en(write_en),
    .write_addr(write_addr),
    .data_in(data_in),

    .clk_read(clk_read),
    .rst_read(rst_read),
    .read_en(read_en),
    .read_addr(read_addr),
    .data_out(data_out),

    .full(full)
);

// Synchronizer intance to synchronize read pointer to write clock domain 
synchronizer #(
    .DATA_WIDTH(POINTER_WIDTH)
) synchronizer_to_write (
    .clk_dest(clk_write),
    .rst_dest(rst_write),
    .data_in(read_ptr_grey),
    .data_out(synch_read_ptr_grey)
);

// FIFO write pointer, address and full flag logic
fifo_write #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .POINTER_WIDTH(POINTER_WIDTH)
) fifo_write_inst(
    .clk_write(clk_write),
    .rst_write(rst_write),
    .write_en(write_en),
    .read_ptr_grey(synch_read_ptr_grey),

    .write_addr(write_addr),
    .write_ptr_grey(write_ptr_grey),
    .full(full)
);

// Synchronizer intance to synchronize write pointer to read clock domain 
synchronizer #(
    .DATA_WIDTH(POINTER_WIDTH)
) synchronizer_to_read (
    .clk_dest(clk_read),
    .rst_dest(rst_read),
    .data_in(write_ptr_grey),
    .data_out(synch_write_ptr_grey)
);

// FIFO read pointer, address and empty flag logic
fifo_read #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .POINTER_WIDTH(POINTER_WIDTH)
) fifo_read_inst(
    .clk_read(clk_read),
    .rst_read(rst_read),
    .read_en(read_en),
    .write_ptr_grey(synch_write_ptr_grey),

    .read_addr(read_addr),
    .read_ptr_grey(read_ptr_grey),
    .empty(empty)
);
    
endmodule