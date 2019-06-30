module debounce_edge_detect (clk, rst, signal, rise, fall);
    input clk; input rst;
    input signal; output rise; output fall;

    wire signal_debounced;

    debounce signal_debouncer (
        .clk(clk), .rst(rst),
        .signal_in(signal),
        .signal_out(signal_debounced)
    );

    edge_detect signal_edge_detector (
        .clk(clk), .rst(rst),
        .signal(signal_debounced),
        .rise(rise), .fall(fall)
    );
endmodule
