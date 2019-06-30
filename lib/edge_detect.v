module edge_detect (clk, rst, signal, rise, fall, change);
    input clk; input rst;
    input signal;
    output reg rise; output reg fall;
    output reg change;

    reg [1:0] sig;

    always @ (posedge clk) if(rst) begin
        rise <= 0; fall <= 0; change <= 0; sig <= 2'b00;
    end else begin
        sig <= {sig[0], signal};
        rise <= 0; fall <= 0; change <= 0;
        if(sig[0] == 1 && sig[1] == 0) rise <= 1;
        if(sig[0] == 0 && sig[1] == 1) fall <= 1;
        if(sig[0] != sig[1]) change <= 1;
    end
endmodule
