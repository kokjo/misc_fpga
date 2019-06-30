module blinky (
    clk, rst,
    blinky
);
    parameter COUNT = 12000000;
    localparam BITS = $clog2(COUNT);

    input clk; input rst;
    output reg blinky;

    reg [$clog2(COUNT)-1:0] cnt;

    always @ (posedge clk) if(rst) begin
        cnt <= 0;
        blinky <= 0;
    end else begin
        cnt <= cnt - 1;
        if(cnt == 0) begin
            blinky <= !blinky;
            cnt <= COUNT;
        end
    end
endmodule
