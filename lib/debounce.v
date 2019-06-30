module debounce (clk, rst, signal_in, signal_out, stable);
    parameter BITS = 8;
    input clk; input rst;
    input signal_in;
    output reg signal_out;
    output stable;
    
    reg [1:0] sig;
    reg [BITS-1:0] cnt = 0;
    assign stable = &cnt;

    always @ (posedge clk) if(rst) begin
        cnt <= 0;
    end else begin
        sig <= {sig[0], signal_in};    
        cnt <= 0;
        if(sig[0] == sig[1]) cnt <= cnt + !stable;
        if(stable) signal_out <= sig[1];
    end
endmodule
