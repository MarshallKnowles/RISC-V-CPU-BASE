`timescale 1ns /100ps
module alu_tb();
//Data types
logic [31:0] op1, op2, result;
logic [4:0] opSel;
logic valid;

//instantiate
alu dut( .opSel(opSel), .op1(op1), .op2(op2), .result(result) );

//generate
initial 
begin
    op1 = $urandom_range(2**31);
    op2 = $urandom_range(2**31);
    opSel = 0;
    #10;
    opSel = 1;
    #10
    opSel = 10;
end

//collect
initial 
begin
    #5
    if(result == (op1 + op2))
        valid = 1;
    else 
        valid = 0;
    #10
    if(result == (op1-op2))
        valid = 1;
    else    
        valid = 0;
    #10
    if(result == 0)
        valid = 1; 
    else
        valid = 0;
end
endmodule