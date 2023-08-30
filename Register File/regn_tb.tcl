#quit current sim
quit -sim
#create or access work library
vlib work;

#compile all code
vlog *.v

#start simulation
vsim work.regn_tb

#watch the waveforms
add wave {/*}

#run the sim
run 100ns