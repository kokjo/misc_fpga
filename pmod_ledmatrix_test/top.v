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
    output led_r; output led_g; output led_b;
    
    localparam COUNT = 600000;

    output flash_cs;
    output flash_clk;
    inout [3:0] flash_io;

    inout [7:0] pmod_2;
    inout [7:0] pmod_1a;
    inout [7:0] pmod_1b;

    wire clk = clk_12mhz;
    wire rst;

    assign led_red = !rst;
    assign led_r = 1;
    assign led_g = 1;
    assign led_b = 1;
    assign flash_cs = 1;
    assign flash_clk = 1;

    wire [63:0] pixels;

    reg [$clog2(COUNT)-1:0] cnt;

    power_on_reset por (
        .clk(clk), .rst(rst),
        .external_reset(button)
    );

    lfsr #(
        .TAPS(64'h800000000000000d),
        .INIT(64'h8000000000000001)
    ) pixels_gen (
        .clk(clk), .rst(rst),
        .step(cnt == 0),
        .out(pixels)
    );

    pmod_ledmatrix led_matrix (
        .clk(clk), .rst(rst),
        .pmod_a(pmod_1a),
        .pmod_b(pmod_1b),
        .pixels(pixels)
    );

    blinky blinky (
        .clk(clk), .rst(rst),
        .blinky(led_green)
    );

    always @ (posedge clk) if(rst) begin
        cnt <= 0;
    end else begin
        cnt <= cnt == 0 ? COUNT : cnt - 1;
    end

endmodule

