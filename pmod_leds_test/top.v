`default_nettype none
module top (
    clk_12mhz,
    uart_rx, uart_tx,
    button, led_green, led_red,
    led_r, led_g, led_b,
    flash_cs,
    flash_clk,
    flash_io,
    pmod_1a, pmod_1b, pmod_2
);
    input clk_12mhz;
    input uart_rx; output reg uart_tx = 1;
    input button; output led_green; output led_red;
    output led_r = 1; output led_g = 1; output led_b = 1;

    output flash_cs = 1;
    output flash_clk = 1;
    inout [3:0] flash_io;

    inout [7:0] pmod_2;
    inout [7:0] pmod_1a;
    inout [7:0] pmod_1b;

    wire clk = clk_12mhz;
    wire rst;

    reg [31:0] counter;
    reg [15:0] leds;
    reg direction;

    power_on_reset por (
        .clk(clk), .rst(rst),
        .external_reset(button)
    );

    assign led_red = !rst;

    pmod_leds pmod_1a_leds (
        .clk(clk), .rst(rst),
        .pmod(pmod_1a),
        .leds(leds[7:0])
    );

    pmod_leds pmod_1b_leds (
        .clk(clk), .rst(rst),
        .pmod(pmod_1b),
        .leds(leds[15:8])
    );

    blinky blinky (
        .clk(clk), .rst(rst),
        .blinky(led_green)
    );

    always @ (posedge clk) if(rst) begin
        leds = 16'd1;
        counter <= 0;
        direction <= 1;
    end else begin
        counter <= counter - 1; 
        if(counter == 0) begin
            counter <= 300000;
            leds = direction ? leds << 1 : leds >> 1;
            if(leds[15] || leds[0]) direction <= !direction;
        end
    end

endmodule

