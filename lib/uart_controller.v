`default_nettype none
module uart_controller (
    clk, rst,
    clkdiv,
    tx, rx,
    rx_data, rx_valid, rx_ready,
    tx_data, tx_valid, tx_ready,
    cmd_data, cmd_valid, cmd_ready
);
    parameter ESC_CODE = 8'hff;

    input clk; input rst;

    input [31:0] clkdiv;

    output tx; input rx;

    output reg [7:0] rx_data;
    output reg rx_valid; input rx_ready;

    input [7:0] tx_data;
    input tx_valid; output tx_ready;

    output reg [7:0] cmd_data;
    output reg cmd_valid; input cmd_ready;
    
    wire rx0_recv;
    wire [7:0] rx0_data;
    wire rx0_busy;

    wire tx0_send;
    wire [7:0] tx0_data;
    wire tx0_busy;
    
    reg escape;

    uart_rx rx0 (
        .clk(clk), .rst(rst),
        .clkdiv(clkdiv),
        .recv(rx0_recv),
        .busy(rx0_busy),
        .data(rx0_data),
        .rx(rx)
    );

    uart_tx tx0 (
        .clk(clk), .rst(rst),
        .clkdiv(clkdiv),
        .send(tx0_send),
        .busy(tx0_busy),
        .data(tx0_data),
        .tx(tx)
    );

    assign tx0_send = tx_valid;
    assign tx_ready = !tx0_busy;
    assign tx0_data = tx_data;

    always @ (posedge clk) if(rst) begin
        rx_data <= 0;
        rx_valid <= 0;

        cmd_data <= 0;
        cmd_valid <= 0;

        escape <= 0; 
    end else begin
        if(rx_ready) rx_valid <= 0;
        if(cmd_ready) cmd_valid <= 0;

        if(rx0_recv) begin
            escape <= 0;
            if(escape && rx0_data != ESC_CODE) begin
                cmd_data <= rx0_data;
                cmd_valid <= 1;
            end else if(!escape && rx0_data == ESC_CODE) begin
                escape <= 1;
            end else begin
                rx_data <= rx0_data;
                rx_valid <= 1;
            end
        end
    end
endmodule
