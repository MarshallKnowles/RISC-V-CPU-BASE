module dec5to32(
    input [4:0] data_in,
    output [31:0] data_out
);


assign data_out = 2**data_in;



endmodule