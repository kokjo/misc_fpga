module stack (clk, rst, push, pop, empty, full, rdata, wdata);
    parameter DEPTH = 8;
    parameter WIDTH = 32;

    localparam WORDS = 1 << DEPTH;

    input clk; input rst;
    input push; input pop;
    output empty; output full;
    output reg [WIDTH-1:0] rdata;
    input [WIDTH-1:0] wdata;

    reg [WIDTH-1:0] mem [0:WORDS-1];
    reg [DEPTH-1:0] top;

    assign empty = (top == 0);
    assign full = (top == WORDS-1);

    assign rdata = mem[top];

    always @ (posedge clk) if(rst) begin
        rdata = 0; 
        top = 0;
    end else begin
        if(push && !full) begin
            top = top + 1;
            mem[top] <= wdata;
        end
        if(pop && !empty) begin
            top = top - 1;
        end
    end
    
endmodule
