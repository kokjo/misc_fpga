`default_nettype none
module random_source (
    clk, rst,
    valid, ready, data
);
    parameter BITS = 8;
    parameter SPEED = 2;
    input clk; input rst;
    output reg valid; input ready; output reg [BITS-1:0] data;

    wire [63:0] rnd;
    
    lfsr #(
        .TAPS(64'h8000000000001713)
    ) random_generator (
        .clk(clk), .rst(rst),
        .step(1'b1), .out(rnd)
    );

    always @ (posedge clk) if(rst) begin
        valid = 0;
        data <= 0;
    end else begin
        if(ready) valid = 0;
        if(!valid && rnd[SPEED-1:0] == 0) begin
            valid = 1;
            data <= rnd >> SPEED;
        end
    end

endmodule 
