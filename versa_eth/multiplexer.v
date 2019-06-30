module multiplexer (
    clk, rst,
    request, grant, valid, ready, error, data,
    requests, grants, valids, readys, errors, datas,
);
    parameter PORTS = 2;
    input clk; input rst;
    output reg request; input grant;
    output reg valid; input ready; output reg error; output reg [7:0] data;
    input [PORTS-1:0] requests; output reg [PORTS-1:0] grants;
    input [PORTS-1:0] valids; output reg [PORTS-1:0] readys; input [PORTS-1:0] errors; input [8*PORTS-1:0] datas;

    reg busy;

    reg [$clog2(PORTS)-1:0] ch;

    integer i, j;
    reg granted;

    always @ (*) for(i = 0; i < PORTS; i = i + 1) begin
        grants[i] <= busy && requests[i] && ch == i; 
    end

    always @ (posedge clk) if(rst) begin
        request <= 0;
        valid <= 0;
        error <= 0;
        data <= 0;
        busy <= 0;
    end else if(!busy) begin
        request <= &requests;
        granted = 0;
        for(i = 0; i < PORTS; i = i +1) begin
            if(grant && !granted && requests[i]) begin
                ch <= i;
                granted = 1;
                busy <= 1;
            end
        end
    end else if(requests[ch]) begin
        if(valid) begin
            if(ready) begin
                valid <= valids[ch];
                error <= errors[ch];
                data <= datas[(ch+1)*8-1:ch*8];
                readys[ch] <= 1;
            end
        end
    end else begin
        request <= 0;
        busy <= 0;
    end
endmodule
