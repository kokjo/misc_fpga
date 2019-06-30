`default_nettype none
module power_on_reset (clk, rst, external_reset);
    parameter DEBOUNCE_EXTERNAL_RESET = 1;
    parameter BITS = 8;
    input clk; output reg rst;
    input external_reset;

    wire external_reset_dbc;
    wire extrst = DEBOUNCE_EXTERNAL_RESET ? external_reset_dbc : external_reset;

    reg [BITS-1:0] reset_cnt = 0;
    wire reset = &reset_cnt;
    
    debounce external_reset_debounce (
        .clk(clk), .rst(1'b0),
        .signal_in(external_reset),
        .signal_out(external_reset_dbc)
    );

    always @ (posedge clk) begin
        reset_cnt <= reset_cnt + !reset; 
        rst <= !reset;
        if(!extrst) reset_cnt <= 0;
    end
endmodule
