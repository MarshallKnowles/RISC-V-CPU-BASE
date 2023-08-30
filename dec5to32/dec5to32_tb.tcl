#quit current sim
quit -sim
#create or access work library
vlib work;

#compile all code
vlog dec5to32.v
vlog dec5to32_tb.sv

#start simulation
vsim work.dec5to32_tb

#watch the waveforms
add wave {/*}

#run the sim
run 100ns