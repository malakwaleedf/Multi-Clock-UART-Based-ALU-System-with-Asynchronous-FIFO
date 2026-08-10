module rst_sync #(
    parameter NUM_STAGES = 2 // parameter indicating the number of synch stages
) (
    input RST, // input asynch rest
    input CLK, // design clock
    output SYNC_RST // output synch reset (asynch assertion, synch deassertion)
);

    reg [NUM_STAGES-1 : 0] sync_rst_reg;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            sync_rst_reg <= 'b0;
        end
        else begin
            sync_rst_reg <= {sync_rst_reg[NUM_STAGES-2 : 0], 1'b1};
        end
    end

    assign SYNC_RST = sync_rst_reg[NUM_STAGES-1];
    
endmodule