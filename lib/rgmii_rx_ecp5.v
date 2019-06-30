`default_nettype none
module rgmii_rx_ecp5 (
    input pad_rx_clk, input pad_rx_ctl, input [3:0] pad_rx_dat,
    output clk, input rst,
    output reg valid, output reg error, output reg [7:0] data,
);
    wire rx_ctl; wire rx_err;
    wire [7:0] rx_dat;

    rgmii_delay_iddr_ecp5 delay_iddr_rx_ctl (
        .clk(pad_rx_clk), .rst(rst),
        .d(pad_rx_ctl),
        .q0(rx_ctl), .q1(rx_err),
    );

    rgmii_delay_iddr_ecp5 delay_iddr_rx_dat [0:3] (
        .clk(pad_rx_clk), .rst(rst),
        .d(pad_rx_dat),
        .q0(rx_dat[3:0]), .q1(rx_dat[7:4]),
    );

    assign clk = pad_rx_clk;

    always @ (posedge clk) if(rst) begin
        valid <= 0;
        error <= 0;
        data <= 0;
    end else begin
        valid <= rx_ctl;
        error <= ~rx_err;
        data <= rx_dat;
    end
endmodule

module rgmii_delay_iddr_ecp5 (
    input clk, input rst,
    input d, output q0, output q1
);
    wire delay_output;

    DELAYF #(
        .DEL_MODE("SCLK_ALIGNED"),
        .DEL_VALUE("DELAY80") // 2ns = 80 * 25ps
    ) delay (
        .A(d),
        .LOADN(1), .MOVE(0), .DIRECTION(0),
        .Z(delay_output)
    );

    IDDRX1F iddr (
        .SCLK(clk), .RST(rst),
        .D(delay_output),
        .Q0(q0), .Q1(q1)
    );
endmodule
