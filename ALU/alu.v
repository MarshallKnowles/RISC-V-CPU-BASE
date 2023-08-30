module alu  (
    input [4:0] opSel,
    input [31:0] op1, op2,
    output reg [31:0] result
);

always @(*)
begin
    
    case (opSel)
        0: result = op1 + op2;
        1: result = op1 - op2;
        default: result = 0;    
    endcase
end


endmodule