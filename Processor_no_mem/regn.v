module regn(
	input signed [31:0] din,
	input clk, enable, reset,
	output reg signed [31:0] dout
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