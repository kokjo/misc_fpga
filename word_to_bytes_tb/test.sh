#!/bin/sh
set -ev
iverilog -o tb.vvp *.v
./tb.vvp
