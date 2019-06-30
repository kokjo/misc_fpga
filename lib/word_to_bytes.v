`default_nettype none
module word_to_bytes (
    clk, rst,
    word_valid, word_ready, word_data,
    byte_valid, byte_ready, byte_data,
);
    parameter BYTES_PER_WORD = 4;
    parameter WORD_SIZE = 8*BYTES_PER_WORD;
    parameter SLOW = 0;
    input clk; input rst;
    input word_valid; output reg word_ready; input [WORD_SIZE-1:0] word_data;
    output reg byte_valid; input byte_ready; output [7:0] byte_data;

    reg busy;
    reg busy_next;

    reg [$clog2(BYTES_PER_WORD)-1:0] byte_idx;
    reg [WORD_SIZE-1:0] word;

    assign byte_data = word[7:0];

    always @ (*) begin
        word_ready = 0;
        byte_valid = 0;
        busy_next = busy;

        if(busy) begin
            byte_valid = 1;
            if(byte_idx == (BYTES_PER_WORD-1) && transfer_byte) busy_next = 0;
        end

        if(SLOW ? !busy : !busy_next) begin
            word_ready = 1;
            if(word_valid) busy_next = 1;
        end
    end

    wire transfer_word = word_valid && word_ready;
    wire transfer_byte = byte_valid && byte_ready;

    always @ (posedge clk) if(rst) begin
        busy <= 0;
        byte_idx <= 0;
        word <= 0;
    end else begin
        busy <= busy_next;

        if(transfer_byte) begin
            byte_idx <= byte_idx + 1;
            word <= {8'd0, word[WORD_SIZE-1:8]};
        end

        if(transfer_word) begin
            byte_idx <= 0;
            word <= word_data;
        end
    end

endmodule
