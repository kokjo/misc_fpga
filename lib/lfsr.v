`default_nettype none
module lfsr(clk, rst, step, out);
    parameter BITS = 64;
    parameter TAPS = 64'h800000000000000d;
    parameter INIT = 64'h0000000000000001;

    input clk; input rst;
    input step;
    output reg [BITS-1:0] out;

    always @ (posedge clk) if(rst) begin
        out <= INIT;
    end else if(step) begin
        out <= {out[BITS-2:0], ^(out & TAPS)};
    end

endmodule
