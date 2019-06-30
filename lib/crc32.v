module crc32 (data_in, state_in, state_out);
    parameter POLY = 32'hEDB88320;
    parameter DATA_WIDTH = 8;
    parameter CRC_WIDTH = 32;

    input [DATA_WIDTH-1:0] data_in;
    input [CRC_WIDTH-1:0] state_in;
    output reg [CRC_WIDTH-1:0] state_out;

    integer i;
    always @* begin
        state_out = state_in;
        for(i = 0; i < DATA_WIDTH; i = i + 1) begin
            state_out = (state_out[0] ^ data_in[i])
                      ? (state_out >> 1) ^ POLY
                      : (state_out >> 1);
        end 
    end
endmodule
