#!/bin/sh
set -ev
iverilog -o tb *.v
./tb
