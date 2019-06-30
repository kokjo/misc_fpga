#!/bin/sh
set -ev
yosys -q -p "synth_ice40 -json top.json -top top" *.v
nextpnr-ice40 --hx8k --freq 12 --pcf hx8k.pcf --asc top.asc --json top.json
icepack top.asc top.bin
iceprog top.bin
