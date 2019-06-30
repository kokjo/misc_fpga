`default_nettype none
module logic_analyser (
    capture_clk, capture_trigger, capture_data,
    clk, rst, capture, done,
    mem_addr, mem_data,
);
    parameter CAPTURE_DEPTH = 11;
    localparam CAPTURE_WORDS = 1 << CAPTURE_DEPTH;

    parameter RLE_DATA_WIDTH = 24;
    parameter RLE_LENGTH_WIDTH = 8;
    localparam RLE_WIDTH = RLE_DATA_WIDTH + RLE_LENGTH_WIDTH;

    input capture_clk; input capture_trigger;
    input [RLE_DATA_WIDTH-1:0] capture_data;

    input clk; input rst;
    input capture; output reg done;
    input [CAPTURE_DEPTH-1:0] mem_addr;
    output [RLE_WIDTH-1:0] mem_data;

    wire [RLE_DATA_WIDTH-1:0] rle_data;
    wire [RLE_LENGTH_WIDTH-1:0] rle_length;
    wire rle_ready;
    wire [RLE_WIDTH-1:0] rle_enc;

    reg [CAPTURE_DEPTH-1:0] mem_idx;
    reg [RLE_WIDTH-1:0] rle_capture_mem [0:CAPTURE_WORDS-1];

    run_length_encoder #(
        .DATA_WIDTH(RLE_DATA_WIDTH),
        .LENGTH_WIDTH(RLE_LENGTH_WIDTH)
    ) rle (
        .clk(capture_clk),
        .rst(0),
        .data_in(capture_data),
        .ready(rle_ready),
        .data_out(rle_data),
        .length(rle_length),
    );

    wire capture_stb;

    sync_stb sync_capture_stb (
        .clk1(clk), .clk2(capture_clk),
        .stb_clk1(capture), .stb_clk2(capture_stb)
    );

    wire done_stb;

    sync_stb sync_done_stb (
        .clk1(capture_clk), .clk2(clk),
        .stb_clk1(done), .stb_clk2(done_stb)
    );

    assign rle_enc = {rle_data, rle_length};

    reg [3:0] state;
    localparam IDLE = 0;
    localparam WAIT_FOR_TRIGGER = 1;
    localparam CAPTURING = 2;
    
    always @ (posedge capture_clk) case(state)
        IDLE: if(capture_stb) begin
            done_stb <= 1;
            state <= WAIT_FOR_TRIGGER;
        end
        WAIT_FOR_TRIGGER: if(capture_trigger) begin
            mem_idx <= 0;
            state <= CAPTURING;
        end
        CAPTURING: begin
            if(mem_idx == CAPTURE_WORDS-1) begin
                done_stb <= 1;
                state <= IDLE;
            end
            if(rle_ready) begin
                rle_capture_mem[mem_idx] <= rle_enc;
                mem_idx <= mem_idx + 1;
            end
        end
        default: state <= IDLE;
    endcase

    always @ (posedge clk) if(rst) begin
        done <= 0;
    end else begin
        if(capture) done <= 0;
        if(done_stb) done <= 1;
    end
    
endmodule

module run_length_encoder (clk, rst, data_in, ready, data_out, length);
    parameter DATA_WIDTH = 32;
    parameter LENGTH_WIDTH = 8;
    localparam MAX_LENGTH = (1 << LENGTH_WIDTH) - 1;
    
    input clk; input rst;
    input [DATA_WIDTH-1:0] data_in;
    output reg [DATA_WIDTH-1:0] data_out;
    output ready;
    output reg [LENGTH_WIDTH-1:0] length;

    assign ready = (data_in != data_out) || (length == MAX_LENGTH);

    always @ (posedge clk) if(rst) begin
        ready <= 0;
        data_out <= 0;
        length <= 0;
    end else begin
        length <= length + 1;
        data_out <= data_in;
        if(ready) length <= 0;
    end
    
endmodule

