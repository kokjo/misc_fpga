`default_nettype none
module uart_tx (
    clk, rst,
    clkdiv,
    valid, ready, data,
    tx,
);
    input clk; input rst;
    input [31:0] clkdiv;
    input valid; output ready;
    input [7:0] data;
    output tx;
    
    reg [9:0] pattern;
    reg [3:0] bitcnt;
    
    reg [31:0] clkcnt;

    assign tx = pattern[0];

    reg [1:0] state;
    
    localparam IDLE = 0;
    localparam BUSY = 1;

    assign ready = !valid && state == IDLE;
    
    always @ (posedge clk) if(rst) begin
        state <= IDLE;
        clkcnt <= 0;
        bitcnt <= 0;
        pattern <= 10'b1111111111;
    end else case(state)
        IDLE: begin
            pattern <= 10'b1111111111;
            if(valid) begin
                pattern <= {1'b1, data, 1'b0};
                bitcnt <= 10;
                clkcnt <= clkdiv;
                state <= BUSY;
            end
        end
        BUSY: begin
            clkcnt <= clkcnt - 1;
            if(clkcnt == 0) begin
                clkcnt <= clkdiv;
                pattern <= {1'b1, pattern[9:1]};
                bitcnt <= bitcnt - 1;
                if(bitcnt == 0) state <= IDLE;
            end
        end
    endcase
endmodule
