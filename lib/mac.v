`default_nettype none
module mac_rx (
    input phy_clk, input phy_rst,
    input phy_valid, input phy_error, input [7:0] phy_data,
    output reg mac_valid, output reg mac_error, output reg [7:0] mac_data,
);
    parameter DISCARD_PREAMBLE = 1;
    parameter CHECK_FCS = 1;

    reg [2:0] st;
    localparam IDLE = 0;
    localparam SYNC = 1;
    localparam RECV = 2;
    localparam ERR = 3;

    reg [31:0] fcs;
    wire [31:0] fcs_next;

    crc32 crc32_fcs (
        .data_in(phy_data),
        .state_in(fcs),
        .state_out(fcs_next)
    );

    always @ (posedge phy_clk) if(phy_rst) begin
        st <= 0;
        mac_error <= 0;
    end else begin
        mac_valid <= 0;
        mac_error <= 0;
        case(st)
            IDLE: if(phy_valid) begin
                st <= DISCARD_PREAMBLE ? SYNC : RECV;
            end
            SYNC: if(phy_valid) begin
                fcs <= 32'hffffffff;
                if(phy_data != 8'h55) st <= ERR;
                if(phy_data == 8'hd5) st <= RECV;
            end else begin
                mac_error <= 1;
                st <= ERR;
            end
            RECV: if(phy_valid) begin
                if(CHECK_FCS) fcs <= fcs_next;
                mac_data <= phy_data;
                mac_error <= phy_error;
                mac_valid <= 1;
            end else begin
                if(CHECK_FCS) mac_error <= fcs != 32'hdebb20e3;
                st <= IDLE;
            end
        endcase
    end

endmodule

module mac_rx_ram (
    input phy_clk, input phy_rst,
    input mac_valid, input mac_error, input [7:0] mac_data,
    
    input clk, input rst,
    input capture, output reg done,
    output reg [11:0] pkt_length,
    input [11:0] pkt_addr, output [7:0] pkt_data,
);
    reg [1:0] st;
    localparam IDLE = 0;
    localparam WAIT = 1;
    localparam RECV = 3;

    reg [7:0] mem [0:4096];
    reg [11:0] pkt_idx;
    reg [11:0] pkt_length_phy;

    wire capture_phy;
    reg done_phy;

    sync_stb capture_stb (
        .clk1(clk), .clk2(phy_clk),
        .stb_clk1(capture), .stb_clk2(capture_phy)
    );
    
    sync_stb done_stb (
        .clk1(phy_clk), .clk2(clk),
        .stb_clk1(done_phy), .stb_clk2(done_stb),
    );
    
    always @ (posedge phy_clk) if (phy_rst) begin
        st <= IDLE;
        done_phy <= 1;
        pkt_length_phy <= 0;
    end else begin
        done_phy <= 0;
        pkt_idx <= 0;
        case(st)
            IDLE: if(capture_phy) st <= WAIT;
            WAIT: if(!mac_valid) st <= RECV;
            RECV: if(mac_valid) begin
                mem[pkt_idx] <= mac_data;
                pkt_idx <= pkt_idx + 1;
                st <= RECV;
                if(mac_error) st <= WAIT;
            end else if(pkt_idx != 0) begin
                if(mac_error) begin
                    st <= WAIT;
                end else begin
                    done_phy <= 1;
                    pkt_length_phy <= pkt_idx;
                    st <= IDLE;
                end
            end
            default: st <= IDLE;
        endcase
    end

    assign pkt_data = mem[pkt_addr];

    always @ (posedge clk) if(rst) begin
        pkt_length <= 0;
        done <= 0;
    end else begin
        if(capture) begin
            pkt_length <= 0;
            done <= 0;
        end
        if(done_stb) begin
            pkt_length <= pkt_length_phy;
            done <= 1;
        end
    end
    
endmodule

module mac_tx (
    input phy_clk, input phy_rst,
    input phy_valid, input phy_error, input phy_data,
);
endmodule
