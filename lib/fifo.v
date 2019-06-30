`default_nettype none
module sync_fifo (
    input clk, input rst,

    input wr_valid,
    output reg wr_ready,
    input [7:0] wr_data,

    output reg rd_valid,
    input rd_ready,
    output reg [7:0] rd_data
);
    parameter SIZE = 1024;
    localparam DEPTH = $clog2(SIZE);

    reg [DEPTH-1:0] wr_ptr;
    reg [DEPTH-1:0] rd_ptr;

    reg [7:0] fifo [SIZE:0];

    wire full = rd_ptr == wr_ptr + 1;
    wire empty = rd_ptr == wr_ptr;

    always @ (posedge clk) if(rst) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
    end else begin
        wr_ready <= 0;
        if(!full && wr_valid) begin
            wr_ptr <= wr_ptr + 1;
            fifo[wr_ptr] <= wr_data;
            wr_ready <= 1;
        end
        if(rd_ready) rd_valid <= 0;;
        if(!empty && rd_ready) begin
            rd_valid <= 1;
            rd_data <= fifo[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

endmodule

module async_fifo (
    input wclk, input wrst,
    input push, input [7:0] wdata,
    output full,

    input rclk, input rrst,
    input pop, output [7:0] rdata,
    output empty,
);
    parameter SIZE = 1024;
    localparam DEPTH = $clog2(SIZE);

    reg [7:0] fifo [SIZE:0];
    reg [DEPTH-1:0] rptr;
    reg [DEPTH-1:0] wptr;

    always @ (posedge wclk) if(wrst) begin
        wptr <= 0;
    end else begin
        if(push) begin
            fifo[wptr] <= wdata;
            wptr <= wptr + 1;
        end
    end

    always @ (posedge rclk) if(rrst) begin
        rptr <= 0;
    end else begin
        if(pop) begin
            rdata <= fifo[rptr];
            rptr <= rptr + 1;
        end
    end

endmodule

