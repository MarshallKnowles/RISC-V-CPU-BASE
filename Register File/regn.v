module regn(
	input [31:0] din,
	input clk, enable, reset,
	output reg [31:0] dout
	);
	
	//set and retrieve data
	always @(posedge clk)
	begin
	    if(reset)
		    dout <= 32'h0000;
	    else if(enable)
		    dout <= din;
	end
	
endmodule