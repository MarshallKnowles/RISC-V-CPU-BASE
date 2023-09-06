module dec5to32(
    input [4:0] dIn,
    output [31:0] dOut
);


assign dOut = 2**dIn;



endmodule