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
    input button; output led_green; output reg led_red;
    output led_r = 1; output led_g = 1; output led_b = 1;

    output flash_cs = 1;
    output flash_clk = 1;
    inout [3:0] flash_io;

    inout [7:0] pmod_2;
    inout [7:0] pmod_1a;
    inout [7:0] pmod_1b;

    wire clk = clk_12mhz;
    wire rst;

    power_on_reset por (
        .clk(clk), .rst(rst),
        .external_reset(button)
    );

    pmod_controller pmod2_ctrl (
        .clk(clk), .rst(rst),
        .pmod(pmod_2)
    );

    reg [31:0] counter;
    reg blinky;

    always @ (posedge clk) if(rst) begin
        counter <= 0;
        blinky <= 0;
    end else begin
        counter <= counter - 1;
        if(counter == 0) begin
            counter <= 12000000;
            blinky <= !blinky;
        end
    end

    assign led_green = blinky;
    assign led_red = !rst;
endmodule

