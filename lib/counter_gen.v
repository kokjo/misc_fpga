`default_nettype none
module counter_gen (
    clk, rst,
    valid, ready, data
);

    input clk; input rst;
    output reg valid; input ready;
    output reg [7:0] data;

    always @ (posedge clk) if(rst) begin
        valid <= 0;
        data <= 0;
    end else begin
        valid <= 1;
        if(ready) data <= data + 1;
    end

endmodule
