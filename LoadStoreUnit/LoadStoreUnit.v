module loadStoreUnit (
    input [31:0] address,
    input clk, wren,
    input [2:0] funct3,
    input signed [31:0] procData,
    output signed [31:0] memData;
)

//wires for the memory unit 
wire [8:0] memAddress; //bc I'm using a smaller memory
wire [3:0] byteEn; //enables bytes from the given address


//parameterize the Load and Stores
parameter LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101;
parameter SB = 3'b000, SH = 3'b001, SW = 3'b010;

//real
wire [1:0] sizeSelect;
assign sizeSelect = funct3[1:0];

//case statement for how long each of the bits are.
always @(*)
    case (sizeSelect)
        LB: begin
            
        end

        LH: begin

        end

        LBU: begin

        end

        LHU: begin

        end
        LW: begin

        end
        default: 
    endcase




endmodule