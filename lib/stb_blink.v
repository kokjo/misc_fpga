module stb_blink(clk, rst, stb, blink);
    input clk; input rst; input stb;
    output reg blink;

    parameter COUNT = 120000;

    reg [$clog2(COUNT):0] cnt;

    always @ (posedge clk) if(rst) begin
        cnt <= 0;
    end else begin
        blink <= 0;
        if(stb) cnt <= COUNT;
        if(cnt != 0) begin
            cnt <= cnt - 1;
            blink <= 1;
        end
    end
endmodule
