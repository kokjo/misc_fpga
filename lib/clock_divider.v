module clock_divider (clk, rst, divider, clk_out);
    input clk;
    input rst;
    input [31:0] divider;
    output reg clk_out;

    reg [31:0] counter;

    always @ (posedge clk) if(rst) begin
        clk_out <= 0;
        counter <= 0;
    end else begin
        if(counter == 0) begin
            counter <= divider;
        end else begin
            counter <= counter - 1;
        end
    end
endmodule
