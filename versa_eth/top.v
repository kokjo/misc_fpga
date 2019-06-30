`default_nettype none
module top (
    input clk_100mhz,
    output [7:0] led,
    output tx, input rx,

    output pad_phy1_config, output pad_phy1_resetn,
    inout pad_phy1_mdio, output pad_phy1_mdc,

    input pad_phy1_rx_clk,
    input pad_phy1_rx_ctl,
    input [3:0] pad_phy1_rx_dat,

    output pad_phy1_tx_clk,
    output pad_phy1_tx_ctl,
    output [3:0] pad_phy1_tx_dat,

    output [45:0] expcon,
    
    input [7:0] switch,
);
    assign pad_phy1_config = 0;
    assign pad_phy1_resetn = 1;

    wire clk_12mhz;
    wire clk = clk_12mhz;
    wire rst;

    wire phy1_clk; wire phy1_rst;

    reg tx_valid;
    wire tx_ready;
    reg [7:0] tx_data;

    wire capture_blink;
    wire done_blink;

    wire phy1_rx_valid;
    wire phy1_rx_error;
    wire [7:0] phy1_rx_data;

    wire phy1_tx_valid; wire phy1_tx_error; wire [7:0] phy1_tx_data;

    wire mac1_rx_valid; wire mac1_rx_error; wire [7:0] mac1_rx_data;

    wire capture;
    wire done;
    wire [11:0] pkt_length;
    reg [11:0] pkt_addr;
    wire [7:0] pkt_data;

    reg [7:0] state;

    localparam CAPTURE = 0;
    localparam WAIT = 1;
    localparam SEND = 2;

    power_on_reset phy1_por (
        .clk(phy1_clk), .rst(phy1_rst),
        .external_reset(1)
    );

    power_on_reset por (
        .clk(clk), .rst(rst),
        .external_reset(1)
    );

    pll pll_100mhz_to_12mhz (
        .clki(clk_100mhz),
        .clko(clk_12mhz),
    );

    uart_tx uart_tx (
        .clk(clk), .rst(rst),
        .clkdiv(104),
        .valid(tx_valid), .ready(tx_ready), .data(tx_data),
        .tx(tx),
    );
    
    stb_blink capture_stb_blink (
        .clk(clk), .rst(rst),
        .stb(capture), .blink(capture_blink),
    );

    rgmii_ecp5 phy1 (
        .pad_rx_clk(pad_phy1_rx_clk), .pad_rx_ctl(pad_phy1_rx_ctl), .pad_rx_dat(pad_phy1_rx_dat),
        .pad_tx_clk(pad_phy1_tx_clk), .pad_tx_ctl(pad_phy1_tx_ctl), .pad_tx_dat(pad_phy1_tx_dat),
        .phy_clk(phy1_clk), .phy_rst(phy1_rst),
        .rx_valid(phy1_rx_valid), .rx_error(phy1_rx_error), .rx_data(phy1_rx_data),
        .tx_valid(phy1_tx_valid), .tx_error(phy1_tx_error), .tx_data(phy1_tx_data),
    );


    mac_rx mac_rx (
        .phy_clk(phy1_clk), .phy_rst(phy1_rst),
        .phy_valid(phy1_rx_valid), .phy_error(phy1_rx_error), .phy_data(phy1_rx_data),
        .mac_valid(mac1_rx_valid), .mac_error(mac1_rx_error), .mac_data(mac1_rx_data),
    );


    mac_rx_ram phy1_mac_rx_ram (
        .phy_clk(phy1_clk), .phy_rst(phy1_rst),
        .mac_valid(mac1_rx_valid), .mac_error(mac1_rx_error), .mac_data(mac1_rx_data),
        .clk(clk),  .rst(rst),
        .capture(capture), .done(done),
        .pkt_length(pkt_length), .pkt_addr(pkt_addr), .pkt_data(pkt_data),
    );

    assign phy1_tx_valid = phy1_rx_valid;
    assign phy1_tx_error = phy1_rx_error;
    assign phy1_tx_data = phy1_rx_data;
  
    assign capture = state == CAPTURE;

    always @ (posedge clk) if(rst) begin
        state <= CAPTURE;
        pkt_addr <= 0;
        tx_valid <= 0;
    end else begin
        tx_valid <= 0;
        case(state)
            CAPTURE: state <= WAIT;
            WAIT: if(done) begin
                pkt_addr <= 0;
                state <= SEND;
            end
            SEND: if(tx_ready) begin
                tx_data <= 0;
                state <= CAPTURE;
                if(pkt_addr < pkt_length) begin
                    tx_valid <= 1;
                    tx_data <= pkt_data;
                    pkt_addr <= pkt_addr + 1;
                    state <= SEND;
                end
            end
            default: state <= CAPTURE;
        endcase
    end

    assign led[0] = rx;
    assign led[1] = tx;
    assign led[2] = ~capture_blink;
    assign led[3] = ~done;
    assign led[4] = 1;
    assign led[5] = 1;
    assign led[6] = 1;
    assign led[7] = 1;

    assign expcon = {tx_data[7:0]};
    
endmodule
