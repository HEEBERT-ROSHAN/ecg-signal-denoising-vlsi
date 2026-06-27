#!/bin/bash
# run_modelsim.sh - compile and run the testbench in ModelSim (works in vsim command line)
# usage: bash scripts/run_modelsim.sh

# set work dir
PROJECT_ROOT=$(pwd)

# create results folder
mkdir -p results

# compile
vlog -work work rtl/*.v tb/tb_top.v
if [ $? -ne 0 ]; then
  echo "vlog failed"
  exit 1
fi

# run (console mode)
vsim -c work.tb -do "run -all; quit"
