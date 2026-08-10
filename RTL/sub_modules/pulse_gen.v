module pulse_gen (
    input CLK,
    input RST,
    input LVL_SIG,
    output PULSE_SIG
);

    reg LVL_SIG_DLY1, LVL_SIG_DLY2;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            LVL_SIG_DLY1 <= 1'b0;
            LVL_SIG_DLY2 <= 1'b0;
        end
        else begin
            LVL_SIG_DLY1 <= LVL_SIG;
            LVL_SIG_DLY2 <= LVL_SIG_DLY1;
        end
    end

    assign PULSE_SIG = LVL_SIG_DLY1 && !LVL_SIG_DLY2;
    
endmodule