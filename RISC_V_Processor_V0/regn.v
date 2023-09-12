module regn(
	input signed [31:0] data_in,
	input clk, enable, reset,
	output reg signed [31:0] data_out
	);
	
	//set and retrieve data
	always @(posedge clk)
	begin
	    if(reset)
		    data_out <= 32'h0000;
	    else if(enable)
		    data_out <= data_in;
	end
	
endmodule