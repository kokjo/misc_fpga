`default_nettype none
module top (clk_100mhz, led, tx, rx);
    input clk_100mhz;
    output [7:0] led;
    output tx;
    input rx;

    wire tx_busy;
    wire tx_send;

    wire clk = clk_100mhz;
    wire rst;
    
    power_on_reset por (
        .clk(clk),
        .rst(rst),
        .external_reset(1)
    );

    blinky #(
        .COUNT(50000000)
    ) blinky (
        .clk(clk),
        .rst(rst),
        .blinky(led[1])
    );

    edge_detect ed_blinky_fall (
        .clk(clk), .rst(rst),
        .signal(led[1]),
        .fall(tx_send)
    );

    uart_tx tx0 (
        .rst(rst),
        .clk(clk),
        .clkdiv(868),
        .valid(tx_send),
        .ready(led[0]),
        .data(8'h41),
        .tx(tx),
    );

    assign led[2] = 1;
    assign led[3] = 1;
    assign led[4] = 1;
    assign led[5] = 1;
    assign led[6] = 1;
    assign led[7] = tx;
    
endmodule
