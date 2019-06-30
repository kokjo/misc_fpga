`default_nettype none
module rgmii_tx_ecp5 (
    input pad_tx_clk, output pad_tx_ctl, output [3:0] pad_tx_dat,
    input clk, input rst,
    input valid, input error, input [7:0] data,
);
    reg tx_ctl; reg tx_err;
    reg [7:0] tx_dat;

    rgmii_oddr_delay_ecp5 oddr_delay_tx_ctl (
        .clk(pad_tx_clk), .rst(rst),
        .d0(tx_ctl), .d1(tx_err),
        .q(pad_tx_ctl),
    );

    rgmii_oddr_delay_ecp5 oddr_delay_tx_dat [3:0] (
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

module rgmii_oddr_delay_ecp5 (
    input clk, input rst,
    input d0, input d1,
    output q,
);
    wire oddr_output;
    ODDRX1F oddr (
        .SCLK(clk), .RST(rst),
        .D0(d0), .D1(d1),
        .Q(oddr_output),
    );

    DELAYF #(
        .DEL_MODE("SCLK_ALIGNED"),
        .DEL_VALUE("DELAY0"),
    ) delay (
        .A(oddr_output),
        .LOADN(1), .MOVE(0), .DIRECTION(0),
        .Z(q),
    );
endmodule

