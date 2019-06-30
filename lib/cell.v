module gol_cell (
    clk, rst,
    update,
    alive,
    neighbors,
);
    parameter INIT_VALUE = 0;

    input clk; input rst;
    input update;
    output reg alive;
    input [7:0] neighbors;

    integer i;
    reg [2:0] popcnt;

    always @ (posedge clk) if(rst) begin
        alive <= INIT_VALUE;
    end else begin
        popcnt = 0;
        for(i = 0; i < 8; i = i+1)
            if(neighbors[i])
                popcnt = popcnt + 1;
        if(update) begin
            if(alive) begin
                alive <= popcnt == 2 || popcnt == 3;
            end else begin
                alive <= popcnt == 3;
            end
        end
    end
endmodule
