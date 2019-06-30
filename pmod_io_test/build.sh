#!/bin/sh
set -ev
yosys -q -p "synth_ice40 -json top.json -top top" *.v
nextpnr-ice40 --up5k --freq 12 --pcf ../lib/icebreaker.pcf --asc top.asc --json top.json
icepack top.asc top.bin
iceprog top.bin
