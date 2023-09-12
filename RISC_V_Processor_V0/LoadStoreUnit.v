module LoadStoreUnit (
    input [31:0] address,
    input clk, wren,
    input [2:0] funct3,
    input signed [31:0] data_in,
    output reg signed [31:0] data_out
);

//wires for the memory unit 
reg [3:0] byte_enable; //enables bytes from the given address
wire [31:0] memory_data_out;


//parameterize the Load and Stores
parameter LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101;
parameter SB = 3'b000, SH = 3'b001, SW = 3'b010;

//instantiate RAM unit uses 1 Port RAM IP from Intel
ramOnePort RAM(
	address,
	byte_enable,
	clk,
	dIn,
	wren,
	memory_data_out);



//Differing data sizes and sign-ed-ness assuming misaligned access is permitted.
always @(*)
    begin
        byte_enable = 4'd0;
        case (funct3)
            LB: begin //byte signed
                byte_enable = 4'b0001;
                data_out = { {25{memory_data_out[7]}}, memory_data_out[6:0]};
            end

            LH: begin //half signed
                byte_enable = 4'b011;
                data_out = { {17{memory_data_out[15]}}, memory_data_out[14:0]};
            end

            LBU: begin //byte unsigned
                byte_enable = 4'b001;
                data_out = {24'b0, memory_data_out[7:0]};
            end

            LHU: begin //half unsigned
                byte_enable = 4'b0011;
                data_out = {16'b0, memory_data_out[15:0]};
            end
            LW: begin //whole 32b
                byte_enable = 4'b1111;
                data_out = memory_data_out;
            end
            default: data_out = 32'hXXXXXXXX;
        endcase
    end



endmodule