module forth (clk, rst);
    input clk; input rst;
    
    reg data_push; reg data_pop;
    wire [7:0] data_rdata; wire [7:0] data_wdata;

    reg ctrl_push; reg ctrl_pop;
    wire [7:0] ctrl_rdata; wire [7:0] ctrl_wdata;

    stack data_stack (
        .clk(clk), .rst(rst),
        .push(data_push), .pop(data_pop),
        .rdata(data_rdata), .wdata(data_wdata),
    );

    stack #(
        .DEPTH(8),
        .WIDTH(8),
    ) ctrl_stack (
        .clk(clk), .rst(rst),
        .push(ctrl_push), .pop(ctrl_pop),
        .rdata(ctrl_rdata), .wdata(ctrl_wdata),
    );

    reg [7:0] code [0:255];
    reg [7:0] pc;
    reg [1:0] pops;
    reg [5:0] opcode;

    reg [31:0] data [0:3];

    reg [3:0] st;

    localparam FETCH = 0;
    localparam POP = 1;

    always @ (posedge clk) if(rst) begin
        pc <= 0; 
        data[0] <= 0;
        data[1] <= 0;
        data[2] <= 0;
        data[3] <= 0;
    end else case(st)
        FETCH: begin
            {pops, opcode} <= code[pc];
            st <= pops == 0 ? EXECUTE : POP;
        end
        POP: begin
            data[0] <= data_rdata;
            data[1] <= data[0];
            data[2] <= data[1];
            data[3] <= data[2];
            st <= pops == 0 ? EXECUTE : POP;
        end
        EXECUTE: case(opcode)
            6'b000000: begin
            end
        endcase
    endcase

endmodule
