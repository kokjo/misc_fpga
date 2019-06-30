`default_nettype none
module pmod_ledmatrix (
    clk, rst,
    pmod_a, pmod_b,
    load,
    pixels,
);
    input clk; input rst;
    inout [7:0] pmod_a;
    inout [7:0] pmod_b;

    output load;
    input [63:0] pixels;
    
    wire [7:0] pmod_a_do;
    wire [7:0] pmod_b_do;

    reg [7:0] rows;
    reg [7:0] cols;

    reg [63:0] pixels_r;
    reg [2:0] idx;
    reg [2:0] cnt;

    assign pmod_a_do = {rows[0], rows[2], rows[4], rows[6],
                        rows[1], rows[3], rows[5], rows[7]};
    assign pmod_b_do = {cols[6], cols[4], cols[2], cols[0],
                        cols[7], cols[5], cols[3], cols[1]};

    assign load = cnt == 7 && idx == 7;

    tristate_buffer tribuf_a [7:0] (
        .pin(pmod_a), .oe(8'hff), .do(pmod_a_do)
    );

    tristate_buffer tribuf_b [7:0] (
        .pin(pmod_b), .oe(8'hff), .do(pmod_b_do)
    );

    always @ (posedge clk) if(rst) begin
        cnt <= 0;
        pixels_r <= pixels;
        idx <= 0;
        rows <= 8'b00000000;
        cols <= 8'b11111111;
    end else begin
        rows <= pixels >> (8*idx);
        cols <= ~(1 << idx);
        cnt <= cnt + 1;
        if(cnt == 7) begin
            rows <= 8'b00000000;
            cols <= 8'b11111111;
            idx <= idx + 1;
            if (load) begin
                pixels_r <= pixels;
            end
        end
    end

endmodule
