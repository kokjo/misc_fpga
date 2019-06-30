module pmod_controller (clk, rst, pmod);
    input clk; input rst;
    inout [7:0] pmod;

    wire [7:0] pmod_oe; wire [7:0] pmod_do; wire [7:0] pmod_di;

    wire [2:0] btns; wire [4:0] leds;
    wire [2:0] btns_click;

    reg [4:0] counter;

    assign leds = counter;

    pmod_io #(
        .DEBOUNCE_BUTTONS(1)
    ) pmod_io (
        .clk(clk), .rst(rst),
        .pmod(pmod),
        .leds(leds), .btns(btns)
    );

    edge_detect btn0_edge_detect (
        .clk(clk), .rst(rst), .signal(btns[0]), .fall(btns_click[0])
    );

    edge_detect btn1_edge_detect (
        .clk(clk), .rst(rst), .signal(btns[1]), .fall(btns_click[1])
    );

    edge_detect btn2_edge_detect (
        .clk(clk), .rst(rst), .signal(btns[2]), .fall(btns_click[2])
    );

    always @ (posedge clk) if(rst) begin
        counter <= 0;
    end else begin
        if(btns_click[0]) counter <= counter + 1;
        if(btns_click[1]) counter <= counter - 1;
        if(btns_click[2]) counter <= 0;
    end
endmodule
