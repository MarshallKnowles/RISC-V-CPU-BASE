module alu  (
    input signed [2:0] op_Select,
    input signed [31:0] op1, 
    input signed [31:0] op2,
    input alt_operator, branch_mode,
    output reg signed [31:0] result
);
wire [31:0] op1_unsign, op2_unsign;
assign op1_unsign = op1;
assign op2_unsign = op2;

always @(*)
begin
    if(branch_mode)
    begin
        case (op_select)
        3'b000: result = (op1 == op2) ? 1'b1 : 1'b0;
        3'b001: result = (op1 != op2) ? 1'b1 : 1'b0;
        3'b100: result = (op1 < op2) ? 1'b1 : 1'b0;
        3'b101: result = (op1 > op2) ? 1'b1 : 1'b0;
        3'b110: result = (op1_unsign < op2_unsign) ? 1'b1 : 1'b0;
        3'b111: result = (op1_unsign < op2_unsign) ? 1'b1 : 1'b0;
        default: result = 0;    
    endcase

    end

    else
    begin
        case (op_select)
            3'b000: begin
                if(alt_operator == 1'b1)
                    result = op1 - op2; 
                else
                    result = op1 + op2;
            end 
            3'b001: result = op2 << (op1[4:0]);
            3'b010: result = (op1 > op2);
            3'b011: result = (op1_unsign > op2_unsign);
            3'b100: result = op1^op2;
            3'b101: begin
                if(alt_operator == 1'b1)
                    result = (op2 >>> op1);
                else
                    result = (op2 >> op1);
            end
            3'b110: result = op1|op2;
            3'b111: result = op1&op2;
    
            default: result = 0;    
        endcase
    end
end

endmodule