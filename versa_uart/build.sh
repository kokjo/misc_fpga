#!/bin/sh
set -ev
yosys -p "synth_ecp5 -json top.json -top top" *.v
nextpnr-ecp5 --json top.json --lpf ../lib/versa.lpf --textcfg top.config --um-45k --freq 100
ecppack --svf-rowsize 100000 --svf top.svf top.config top.bin
openocd -f ../lib/openocd_versa.cfg -c "transport select jtag; init; svf top.svf; exit"
