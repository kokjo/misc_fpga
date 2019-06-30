module top (clk, leds);
    input clk;
    output [7:0] leds;

    reg [7:0] led_pattern [0:15];
    reg [3:0] led_pattern_selector;

    reg [31:0] counter;

    wire rst;

    assign leds = led_pattern[led_pattern_selector];

    power_on_reset por (
        .clk(clk), .rst(rst),
        .external_reset(1)
    );

    always @ (posedge clk) if(rst) begin
        coutner <= 0;
        led_pattern_selector <= 0;
        led_pattern[0]  <= 8'b00000001;
        led_pattern[1]  <= 8'b00000010;
        led_pattern[2]  <= 8'b00000100;
        led_pattern[3]  <= 8'b00001000;
        led_pattern[4]  <= 8'b00010000;
        led_pattern[5]  <= 8'b00100000;
        led_pattern[6]  <= 8'b01000000;
        led_pattern[7]  <= 8'b10000000;
        led_pattern[8]  <= 8'b01000000;
        led_pattern[9]  <= 8'b00100000;
        led_pattern[10] <= 8'b00010000;
        led_pattern[11] <= 8'b00001000;
        led_pattern[12] <= 8'b00000100;
        led_pattern[13] <= 8'b00000010;
        led_pattern[14] <= 8'b00000001;
        led_pattern[15] <= 8'b00000001;
    end else begin
        counter <= counter + 1;
        if(counter[20]) begin
            counter <= 0;
            led_pattern_selector <= led_pattern_selector + 1;
            if(led_pattern_selector == 13) led_pattern_selector <= 0;
        end
    end
endmodule

