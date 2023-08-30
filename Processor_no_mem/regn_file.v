module regn_file(
    input [31:0] din, reset, enable,
    input [4:0] select,
    input clk,
    output wire [31:0] dout
);
    wire [31:0] doutRegnWires [31:0];
    genvar i;

//register array
generate
    for(i = 0; i<32; i = i +1 ) begin
    regn x(.din(din), .clk(clk), .reset(reset[i]), .enable(enable[i]), .dout(doutRegnWires[i]));

    end
endgenerate

//mux

assign dout = doutRegnWires[select];

endmodule