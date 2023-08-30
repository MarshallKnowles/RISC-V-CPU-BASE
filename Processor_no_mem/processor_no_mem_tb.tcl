#quit current sim
quit -sim
#create or access work library
vlib work;

#compile all code
vlog *.v
#compile testbench
vlog processor_no_mem.sv
vlog processor_no_mem_ctrltb.sv

# start the sim, icluding the verilog library if it's needed
vsim work.processor_no_mem_tb -Lf verilog

#watch the waveforms

#FSM
add wave -label state -radix decimal {/processor_no_mem_tb/DUT/state}
add wave -label nextState -radix decimal {/processor_no_mem_tb/DUT/nextState}

#CORE
add wave -label clk {/processor_no_mem_tb/DUT/clk}
add wave -label reset {/processor_no_mem_tb/DUT/reset}
add wave -label done {/processor_no_mem_tb/DUT/done}
add wave -label IR_enable {/processor_no_mem_tb/DUT/IR_enable}

#register values
add wave -label PC -radix decimal {/processor_no_mem_tb/DUT/PC_dOut}
add wave -label x0 {/processor_no_mem_tb/DUT/mux_dIn[0]}
add wave -label x1 {/processor_no_mem_tb/DUT/genblk1[1]/x/dout}
add wave -label x4 {/processor_no_mem_tb/DUT/genblk1[4]/x/dout}
add wave -label x5 {/processor_no_mem_tb/DUT/genblk1[5]/x/dout}
add wave -label x6 {/processor_no_mem_tb/DUT/genblk1[6]/x/dout}
add wave -label x7 {/processor_no_mem_tb/DUT/genblk1[7]/x/dout}
add wave -label result {/processor_no_mem_tb/DUT/result/dout}
add wave -label op1 {/processor_no_mem_tb/DUT/op1/dout}
#Instrution load
add wave -label IR_enable {/processor_no_mem_tb/DUT/IR_enable}
add wave -label command {/processor_no_mem_tb/command}
add wave -label IR {/processor_no_mem_tb/DUT/IR_out}
#Control Signals
add wave -label gpr_enable {/processor_no_mem_tb/DUT/gpr_enable}
add wave -label mux_sel -radix unsigned {/processor_no_mem_tb/DUT/mux_sel}
add wave -label op1_enable {/processor_no_mem_tb/DUT/op1_enable}
add wave -label result_enable {/processor_no_mem_tb/DUT/result_enable}
#Command Decode
add wave -label funct3 {/processor_no_mem_tb/DUT/funct3}
add wave -label opcode {/processor_no_mem_tb/DUT/opcode}
add wave -label imm_I -radix decimal {/processor_no_mem_tb/DUT/mux_dIn[33]}
add wave -label rs1 -radix decimal {/processor_no_mem_tb/DUT/rs1}
add wave -label rd -radix decimal {/processor_no_mem_tb/DUT/rd}


#fix wave picture
do processor_no_mem_tb_wave.do
# run for all of tb's needed time
run 1000ns
