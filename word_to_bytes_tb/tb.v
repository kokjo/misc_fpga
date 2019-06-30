`default_nettype none
module tb();
    reg clk = 1;
    always clk = #1 !clk;

    wire rst;

    power_on_reset por (
        .clk(clk), .rst(rst),
        .external_reset(1'b1)
    );

    wire word_valid;
    wire word_ready;
    wire [31:0] word_data;

    wire byte_valid;
    wire byte_ready;
    wire [7:0] byte_data;

    random_source #(
        .BITS(32),
        .SPEED(3)
    ) source (
        .clk(clk), .rst(rst),
        .valid(word_valid), .ready(word_ready), .data(word_data)
    );

    word_to_bytes w2b_dut (
        .clk(clk), .rst(rst),
        .word_valid(word_valid), .word_ready(word_ready), .word_data(word_data),
        .byte_valid(byte_valid), .byte_ready(byte_ready), .byte_data(byte_data)
    );

    random_sink #(
        .BITS(8),
        .SPEED(1)
    ) sink (
        .clk(clk), .rst(rst),
        .valid(byte_valid), .ready(byte_ready), .data(byte_data)
    );

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars;
        #100000
        $finish;
    end
endmodule
