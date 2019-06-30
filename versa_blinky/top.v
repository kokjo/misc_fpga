module top (
    input clk_100mhz,
    output [7:0] led,
);
    wire clk = clk_100mhz;
    wire blink;

    blinky #(
        .COUNT(25000000)
    ) blinky (
        .clk(clk),
        .blinky(blink)
    );

    assign led = blink ? 8'hff : 8'h00;
endmodule
