module pmod_leds (
    clk, rst,
    pmod,
    leds,
);
    input clk; input rst;
    inout [7:0] pmod;
    input [7:0] leds;

    wire [7:0] pmod_oe;
    wire [7:0] pmod_do;
    wire [7:0] pmod_di;

    tristate_buffer tribuf [7:0] (
        .pin(pmod), .oe(pmod_oe), .do(pmod_do), .di(pmod_di)
    );

    assign pmod_oe = 8'b11111111;
    assign pmod_do = {
        leds[7], leds[5], leds[3], leds[1],
        leds[6], leds[4], leds[2], leds[0]
    };
endmodule
