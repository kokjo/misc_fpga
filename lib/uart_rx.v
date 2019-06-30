module uart_rx (
    clk, rst,
    clkdiv,
    recv, busy, err,
    data,
    rx
);
    input clk; input rst;
    input [31:0] clkdiv;
    output reg recv; output reg busy; output reg err;
    output reg [7:0] data;
    input rx;
    
    reg [3:0] bitcnt;
    reg [31:0] clkcnt;

    reg [1:0] state;
    localparam IDLE = 0;
    localparam STARTBIT = 1;
    localparam DATABIT = 2;
    localparam STOPBIT = 3;

    wire strobe = clkcnt == 0;

    always @ (posedge clk) if(rst) begin
        recv <= 0; busy <= 0; err <= 0;
        data <= 8'h00;
        bitcnt <= 0;
        clkcnt <= 0;
        state <= IDLE;
    end else begin
        clkcnt <= clkcnt - 1;
        busy <= state != IDLE;
        recv <= 0;
        case(state)
            IDLE: if(rx == 0) begin
                clkcnt <= clkdiv >> 1;
                state <= STARTBIT;
                bitcnt <= 8;
            end
            STARTBIT: if(strobe) begin
                clkcnt <= clkdiv;
                state <= DATABIT;
            end
            DATABIT: if(strobe) begin
                clkcnt <= clkdiv;
                bitcnt <= bitcnt - 1;
                if(bitcnt == 0) begin
                    state <= STOPBIT;
                end else begin
                    data <= {rx, data[7:1]};
                    state <= DATABIT;
                end
            end
            STOPBIT: if(strobe) begin
                clkcnt <= clkdiv;
                if(rx == 1) begin
                    err <= 0; recv <= 1;
                end else begin
                    err <= 1; recv <= 0;
                end
                state <= IDLE;
            end
        endcase
    end
endmodule
