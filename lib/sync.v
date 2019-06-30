`default_nettype none
module sync_flag (
    input clk1, input clk2,
    input flg_clk1, output flg_clk2
);
    reg [1:0] q;

    assign flg_clk2 = q[1];
    
    always @ (posedge clk2) q <= {q[0], flg_clk1};
endmodule

module sync_stb (
    input clk1, input clk2,
    input stb_clk1, output stb_clk2,
);
    reg [2:0] q;
    reg flag = 0;

    always @ (posedge clk1) begin
        if(stb_clk1) flag <= !flag;
    end

    always @ (posedge clk2) begin
        stb_clk2 <= q[2] != q[1];
        q <= {q[1], q[0], flag};
    end
endmodule

module sync_ready_valid (
    input clk1, input rst1, input clk2, input rst2,
    input valid_clk1, output reg ready_clk1,
    output reg valid_clk2, input ready_clk2,
);

    wire valid_stb_clk1;
    wire valid_stb_clk2;

    wire ready_stb_clk1;
    wire ready_stb_clk2;

    sync_stb valid_stb (
        .clk1(clk1), .clk2(clk2),
        .stb_clk1(valid_stb_clk1),
        .stb_clk2(valid_stb_clk2)
    );

    sync_stb ready_stb (
        .clk1(clk2), .clk2(clk1),
        .stb_clk1(ready_stb_clk2),
        .stb_clk2(valid_stb_clk1)
    );

    edge_detect valid_ed (
        .clk(clk1), .rst(0),
        .signal(valid_clk1),
        .rise(valid_stb_clk1)
    );

    edge_detect ready_ed (
        .clk(clk2), .rst(0),
        .signal(ready_clk2),
        .rise(valid_stb_clk2)
    );

    assign ready_clk1 = ready_stb_clk1;

    always @ (posedge clk1) if(rst1) begin
        ready_clk1 <= 0;
    end else begin
        ready_clk1 <= 0;
        if(ready_stb_clk1) ready_clk1 <= 1;
    end

    always @ (posedge clk2) if(rst2) begin
        valid_clk2 <= 0;
    end else begin
        if(valid_stb_clk2) valid_clk2 <= 1;
        if(ready_clk2) valid_clk2 <= 0;
    end

endmodule

module sync_word (
    clk1, rst1, clk2, rst2,
    valid_clk1, ready_clk1, data_clk1,
    valid_clk2, ready_clk2, data_clk2,
);
    parameter WIDTH = 8;
    input clk1; input rst1; input clk2; input rst2;
    input valid_clk1; output reg ready_clk1; input [WIDTH-1:0] data_clk1;
    output reg valid_clk2; input ready_clk2; output reg [WIDTH-1:0] data_clk2;

    wire transfer_stb_clk1;

    

    always @ (posedge clk1) begin
        ready_clk1 <= 1;
    end
endmodule
