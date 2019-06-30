`default_nettype none
module rgmii_ecp5 (
    input pad_rx_clk, input pad_rx_ctl, input [3:0] pad_rx_dat,
    output pad_tx_clk, output pad_tx_ctl, output [3:0] pad_tx_dat,

    output phy_clk, input phy_rst,
    output rx_valid, output rx_error, output [7:0] rx_data,
    input tx_valid, input tx_error, input [7:0] tx_data,
);
    rgmii_rx_ecp5 rx (
        .pad_rx_clk(pad_rx_clk), .pad_rx_ctl(pad_rx_ctl), .pad_rx_dat(pad_rx_dat),
        .clk(phy_clk), .rst(phy_rst),
        .valid(rx_valid), .error(rx_error), .data(rx_data),
    );

    rgmii_tx_ecp5 tx (
        .pad_tx_clk(pad_tx_clk), .pad_tx_ctl(pad_tx_ctl), .pad_tx_dat(pad_tx_dat),
        .clk(phy_clk), .rst(phy_rst), 
        .valid(tx_valid), .error(tx_error), .data(tx_data),
    );
endmodule

module rgmii_rx_ecp5 (
    input pad_rx_clk, input pad_rx_ctl, input [3:0] pad_rx_dat,
    output clk, input rst,
    output reg valid, output reg error, output reg [7:0] data,
);
    parameter DELAY = 80;

    wire rx_ctl; wire rx_err;
    wire [7:0] rx_dat;

    rgmii_delay_iddr_ecp5 #(
        .DELAY(DELAY),
    ) delay_iddr_rx_ctl (
        .clk(pad_rx_clk), .rst(rst),
        .d(pad_rx_ctl),
        .q0(rx_ctl), .q1(rx_err),
    );

    rgmii_delay_iddr_ecp5 #(
        .DELAY(DELAY),
    ) delay_iddr_rx_dat [0:3] (
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

module rgmii_tx_ecp5 (
    input pad_tx_clk, output pad_tx_ctl, output [3:0] pad_tx_dat,
    input clk, input rst,
    input valid, input error, input [7:0] data,
);
    parameter DELAY= 0;

    reg tx_ctl; reg tx_err;
    reg [7:0] tx_dat;

    rgmii_oddr_delay_ecp5 #(
        .DELAY(DELAY),
    ) oddr_delay_tx_ctl (
        .clk(pad_tx_clk), .rst(rst),
        .d0(tx_ctl), .d1(tx_err),
        .q(pad_tx_ctl),
    );

    rgmii_oddr_delay_ecp5 #(
        .DELAY(DELAY),
    ) oddr_delay_tx_dat [3:0] (
        .clk(pad_tx_clk), .rst(rst),
        .d0(tx_dat[3:0]), .d1(tx_dat[7:4]),
        .q(pad_tx_dat),
    );
    
    assign clk = pad_tx_clk;
    
    always @ (posedge clk) if(rst) begin
        tx_ctl <= 0;
        tx_err <= 1;
        tx_dat <= 0;
    end else begin
        tx_ctl <= valid;
        tx_err <= ~error && valid;
        tx_dat <= data;
    end
endmodule

module rgmii_delay_iddr_ecp5 (
    input clk, input rst,
    input d, output q0, output q1
);
    parameter DELAY = 80;
    wire delay_output;

    DELAYF #(
        .DEL_MODE("SCLK_ALIGNED"),
        .DEL_VALUE(DELAY) // 2ns = 80 * 25ps
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

module rgmii_oddr_delay_ecp5 (
    input clk, input rst,
    input d0, input d1,
    output q,
);
    parameter DELAY = 0;
    wire oddr_output;
    ODDRX1F oddr (
        .SCLK(clk), .RST(rst),
        .D0(d0), .D1(d1),
        .Q(oddr_output),
    );

    DELAYF #(
        .DEL_MODE("SCLK_ALIGNED"),
        .DEL_VALUE(DELAY),
    ) delay (
        .A(oddr_output),
        .LOADN(1), .MOVE(0), .DIRECTION(0),
        .Z(q),
    );
endmodule
