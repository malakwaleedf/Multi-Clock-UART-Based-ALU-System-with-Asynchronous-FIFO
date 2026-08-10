module data_sync #(
    parameter NUM_STAGES = 2, // Number of Flip Flop Stages 
    parameter BUS_WIDTH = 8 // Width of synchronized bus
) (
    input [BUS_WIDTH-1 : 0] Unsync_bus, // Unsynchronized data bus
    input  bus_enable, // Source domain enable signal
    input CLK, // Destination domain clock
    input RST, // Destination domain Active Low Asynchronous Reset
    output reg [BUS_WIDTH-1 : 0] sync_bus, // Synchronized data bus
    output reg enable_pulse // Destination domain enable signal
);
    wire enable_pulse_internal; // internal signal for destination domain enable signal
    wire [BUS_WIDTH-1 : 0] sync_bus_comb; // internal bus for synchronized data bus
    reg [NUM_STAGES-1 : 0] bus_enable_reg; // internal bus for source domain enable signal synchronization
    wire bus_enable_sync; // internal signal for sync source domain enable signal
    reg reg_bus_enable_sync; // internal signal for registered sync source domain enable signal

    // synchronized data bus multiplexing 
    assign sync_bus_comb = (enable_pulse_internal)? Unsync_bus : sync_bus;

    // synchronized data bus registering
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            sync_bus <= 'b0;
        end
        else begin
            sync_bus <= sync_bus_comb;
        end
    end

    // bus_enable signal synchronization
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            bus_enable_reg <= 'b0;
        end
        else begin
            bus_enable_reg <= {bus_enable_reg[NUM_STAGES-2 : 0], bus_enable};
        end
    end

    assign bus_enable_sync = bus_enable_reg[NUM_STAGES-1];

    // enable_pulse generation
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            reg_bus_enable_sync <= 1'b0;
        end
        else begin
            reg_bus_enable_sync <= bus_enable_sync;
        end
    end

    assign enable_pulse_internal = bus_enable_sync & (!reg_bus_enable_sync);

    // enable_pulse signal registering
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            enable_pulse <= 1'b0;
        end
        else begin
            enable_pulse <= enable_pulse_internal;
        end
    end



endmodule