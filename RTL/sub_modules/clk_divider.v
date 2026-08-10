module clk_divider (
    input  I_ref_clk, // input reference frequency
    input  I_rst_n, // asynch activr low reset signal
    input I_clk_en, // input clock divider block enable
    input [7:0] I_div_ratio, // input dividing ratio (integer value)
    output reg O_div_clk // output divided clock
);

    localparam zero = 8'b0; // local parameter holding zero (invalid value for div ratio)
    localparam one = 8'b1; // local parameter holding one (invalid value for div ratio)

    wire clk_div_en; // internal signal to enable clock division based on div ratio and block enable signals values
    reg [7:0] counter; // internal bus to count the number of reference clock cycles 
    reg toggle_flag; // internal signal used to toggle when div ration is odd
    wire odd; // internal signal used to indicate if div ration is odd
    wire [7:0] half_toggle; // internal bus to hold half the div ratio value
    wire [7:0] half_toggle_plus_one; // internal bus to hold half the div ratio value plus

    assign clk_div_en = I_clk_en && ( I_div_ratio != zero) && ( I_div_ratio != one);
    assign odd = I_div_ratio[0];
    assign half_toggle = (I_div_ratio >> 1'b1) - 1'b1; 
    assign half_toggle_plus_one = I_div_ratio >> 1'b1;

    always @(posedge I_ref_clk or negedge I_rst_n) begin
        if(!I_rst_n) begin
            O_div_clk <= 1'b0;
            counter <= 8'b0;
            toggle_flag <= 1'b0;
        end
        else if(clk_div_en) begin
            if(!odd && counter == half_toggle) begin
                O_div_clk <= !O_div_clk;
                counter <= 1'b0;
            end
            else if(odd && ((counter == half_toggle && toggle_flag) || (counter == half_toggle_plus_one && !toggle_flag))) begin
                O_div_clk <= !O_div_clk;
                counter <= 1'b0;
                toggle_flag <= !toggle_flag;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end
    
endmodule