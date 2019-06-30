module kr (
    clk, rst,
    leds
);
    parameter COUNT = 32'd1200000;
    input clk; input rst;
    output [7:0] leds;

    reg [31:0] counter;

    reg [7:0] patterns [0:13];
    reg [3:0] pattern_sel;

    initial begin
        patterns[0]  <= 8'b00000001;
        patterns[1]  <= 8'b00000010;
        patterns[2]  <= 8'b00000100;
        patterns[3]  <= 8'b00001000;
        patterns[4]  <= 8'b00010000;
        patterns[5]  <= 8'b00100000;
        patterns[6]  <= 8'b01000000;
        patterns[7]  <= 8'b10000000;
        patterns[8]  <= 8'b01000000;
        patterns[9]  <= 8'b00100000;
        patterns[10] <= 8'b00010000;
        patterns[11] <= 8'b00001000;
        patterns[12] <= 8'b00000100;
        patterns[13] <= 8'b00000010;
    end

    always @ (posedge clk) if(rst) begin
        pattern_sel <= 0;
        counter <= 0; 
    end else begin
        counter <= counter - 1;
        if(counter == 0) begin
            counter <= COUNT;
            pattern_sel <= pattern_sel - 1;
            if(pattern_sel == 0) pattern_sel <= 13;
        end
    end

    assign leds = patterns[pattern_sel];
endmodule
