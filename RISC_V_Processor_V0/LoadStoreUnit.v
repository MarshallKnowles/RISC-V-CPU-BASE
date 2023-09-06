module LoadStoreUnit (
    input [31:0] address,
    input clk, wren,
    input [2:0] funct3,
    input signed [31:0] dIn,
    output reg signed [31:0] dOut
);

//wires for the memory unit 
wire [8:0] memAddress; //bc I'm using a smaller memory
reg [3:0] byteEn; //enables bytes from the given address
wire [31:0] memDOut;


//parameterize the Load and Stores
parameter LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101;
parameter SB = 3'b000, SH = 3'b001, SW = 3'b010;

//instantiate RAM unit uses 1 Port RAM IP from Intel
ramOnePort RAM(
	address,
	byteEn,
	clk,
	dIn,
	wren,
	memDOut);



//Differing data sizes and sign-ed-ness assuming misaligned access is permitted.
always @(*)
    begin
        byteEn = 4'd0;
        case (funct3)
            LB: begin //byte signed
                byteEn = 4'b0001;
                dOut = { {25{memDOut[7]}}, memDOut[6:0]};
            end

            LH: begin //half signed
                byteEn = 4'b011;
                dOut = { {17{memDOut[15]}}, memDOut[14:0]};
            end

            LBU: begin //byte unsigned
                byteEn = 4'b001;
                dOut = {24'b0, memDOut[7:0]};
            end

            LHU: begin //half unsigned
                byteEn = 4'b0011;
                dOut = {16'b0, memDOut[15:0]};
            end
            LW: begin //whole 32b
                byteEn = 4'b1111;
                dOut = memDOut;
            end
            default: dOut = 32'hXXXXXXXX;
        endcase
    end



endmodule