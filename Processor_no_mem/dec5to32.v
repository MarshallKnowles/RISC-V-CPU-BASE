module dec5to32(
    input signed [4:0] dIn,
    output signed [31:0] dOut
);


assign dOut = 2**dIn;



endmodule