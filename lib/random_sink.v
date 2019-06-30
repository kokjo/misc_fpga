`default_nettype none
module random_sink (
    clk, rst,
    valid, ready, data,
);
    parameter BITS = 8;
    parameter SPEED = 2;

    input clk; input rst;
    input valid; output reg ready; input [BITS-1:0] data;

    wire [63:0] rnd;

    reg [BITS-1:0] last;

    lfsr #(
        .TAPS(64'h80000000000019E2)
    ) random_generator (
        .clk(clk), .rst(rst),
        .step(1'b1), .out(rnd)
    );

    always @ (posedge clk) if(rst) begin
        last <= 0;
        ready <= 0;
    end else begin
        if(valid && ready) begin
            ready = 0;
            last <= data;
        end
        if(rnd[SPEED-1:0] == 0) ready = 1;
    end

endmodule
