#quit current sim
quit -sim
#create or access work library
vlib work;

#compile all code
vlog *.v
vlog *.sv

#start simulation
vsim work.alu_tb

#watch the waveforms
add wave {/*}

#run the sim
run 100ns