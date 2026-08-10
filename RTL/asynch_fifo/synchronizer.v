/*
    Synchronizer Module
    Used to synchronize signals between different clock domains
 */
module synchronizer #(
    parameter DATA_WIDTH = 32 // Width of  signal to be synchronized
) (
    input wire clk_dest, // Destination clock
    input wire rst_dest, // Destination domain reset signal
    input wire [DATA_WIDTH-1:0] data_in, // Data input from the source domain (unsynchronized)
    output reg [DATA_WIDTH-1:0] data_out  // Synchronized data output to the destination domain
);

reg [DATA_WIDTH-1:0] sync_reg; // First stage of synchronization

// Synchronization process
always @(posedge clk_dest or negedge rst_dest) begin
    if (!rst_dest) begin
        sync_reg <= 0; 
        data_out <= 0; 
    end else begin
        sync_reg <= data_in; // Capture input data in the first FF (to absorb metastability)
        data_out <= sync_reg; // Output synchronized data
    end   
end
    
endmodule