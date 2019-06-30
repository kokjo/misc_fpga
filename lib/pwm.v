module pwm (clk, rst, value, signal);
    input clk; input rst;
    input [7:0] value;
    output reg signal;

    reg [7:0] counter;

    always @ (posedge clk) if(rst) begin
        counter <= 0;
    end else begin
        counter <= counter + 1;
        signal <= (counter < value);
    end
endmodule
