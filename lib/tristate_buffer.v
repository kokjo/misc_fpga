module tristate_buffer (pin, oe, do, di);
    inout pin; input oe; input do; output di;
    SB_IO #(
        .PIN_TYPE(6'b101001),
        .PULLUP(1'b0)
    ) pmod_2_buf (
        .PACKAGE_PIN(pin),
        .OUTPUT_ENABLE(oe),
        .D_OUT_0(do),
        .D_IN_0(di)
    );
endmodule    

