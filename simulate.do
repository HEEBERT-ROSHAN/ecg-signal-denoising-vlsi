# ============================================================
# simulate.do  – compile & run ECG project testbench
# ============================================================

# Change to your project folder
cd C:/modelsim_work_space/ECG_VLSI_PROJECT

# Clean/create work library
if [file exists work] {
    vdel -all
}
vlib work
vmap work work

# Compile RTL files
vlog rtl/*.v

# Compile testbench
vlog tb/tb_top.v

# Launch simulation (tb_top is your testbench module name)
vsim work.tb_top -voptargs=+acc

# Add all DUT & TB signals to Wave window
add wave -r sim:/tb_top/*

# Zoom full
wave zoom full

# Run long enough to process entire file
# (change time as needed to cover your data file length)
run 500000000 ns   ;# 0.5s of sim time as starting point

# Keep simulation window open after run
view wave
view structure
view signals
