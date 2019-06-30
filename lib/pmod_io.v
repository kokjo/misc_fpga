module pmod_io (
    clk, rst,
    pmod,
    leds, btns
);
    parameter DEBOUNCE_BUTTONS = 1;
    input clk; input rst;
    inout [7:0] pmod;

    wire [7:0] pmod_oe;
    wire [7:0] pmod_do;
    wire [7:0] pmod_di;

    input [4:0] leds;
    output [2:0] btns;

    wire [2:0] btns_raw;
    wire [2:0] btns_dbc;

    assign btns = DEBOUNCE_BUTTONS ? btns_dbc : btns_raw;
    assign btns_raw = {pmod_di[7], pmod_di[3], pmod_di[6]};
    assign pmod_do = {2'b00, leds[3], leds[4], 1'b0, leds[2], leds[1], leds[0]};
    assign pmod_oe = 8'b00110111;

    tristate_buffer tribuf [7:0] (
        .pin(pmod), .oe(pmod_oe), .do(pmod_do), .di(pmod_di)
    );

    debounce btn0_debounce (
        .clk(clk), .rst(rst), .signal_in(btns_raw[0]), .signal_out(btns_dbc[0])
    );

    debounce btn1_debounce (
        .clk(clk), .rst(rst), .signal_in(btns_raw[1]), .signal_out(btns_dbc[1])
    );

    debounce btn2_debounce (
        .clk(clk), .rst(rst), .signal_in(btns_raw[2]), .signal_out(btns_dbc[2])
    );
endmodule
