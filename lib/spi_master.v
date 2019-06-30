`default_nettype none
module spi_master (
    clk, rst,
    clkdiv,
    sck, mosi, miso,
    tx_data, tx_valid, tx_ready,
    rx_data, rx_valid, rx_ready,
    busy,
);
    input clk; input rst;

    input [31:0] clkdiv;

    output reg sck;
    output reg mosi;
    input miso;

    input [7:0] tx_data;
    input tx_valid; output reg tx_ready;

    output [7:0] rx_data;
    output reg rx_valid; input rx_ready;

    output reg busy;

    reg [31:0] clkcnt;
    reg [3:0] bitcnt;

    reg [7:0] obuffer;
    reg [7:0] ibuffer;

    assign rx_data = ibuffer;

    always @ (posedge clk) if(rst) begin
        sck <= 0;
        mosi <= 1;
        tx_ready <= 0;
        rx_valid <= 0;
        
        clkcnt <= 0;
        obuffer <= 8'h00;
        ibuffer <= 8'h00;

        busy <= 0;
    end else begin
        if(rx_ready) rx_valid <= 0;
        if(!busy) begin
            tx_ready <= 1;
            if(tx_valid) begin
                sck <= 0;
                obuffer <= tx_data;
                clkcnt <= clkdiv;
                tx_ready <= 0;
                bitcnt <= 8;
                busy <= 1;
            end
        end else begin
            clkcnt <= clkcnt - 1;
            if(clkcnt == 0) begin
                clkcnt <= clkdiv;
                mosi <= obuffer[7];
                if(sck) begin
                    sck <= 0;
                    obuffer <= {obuffer[6:0], 1'b0};
                    bitcnt <= bitcnt - 1;
                    if(bitcnt == 0) begin
                        busy <= 0;
                        rx_valid <= 1;
                    end
                end else begin
                    sck <= 1;
                    ibuffer <= {ibuffer[6:0], miso};
                end
            end
        end
    end
endmodule
