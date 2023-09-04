`timescale 1ns/1ns

module processor_no_mem_tb();

//initalize data types
logic signed [31:0] regValues [38:0];
logic [31:0]command;
logic clk, reset, run, done;
logic [11:0] imm_B;
logic [19:0] imm_J;

//scoreboard data
logic fail;
integer failNum;
parameter totalTests = 4;

//parameterize for easier testing
//OPCODE PARAMETERIZATIONS
    parameter LOAD = 7'b0000011, LOAD_FP = 7'b0000111, MISC_MEM = 7'b0001111, OP_IMM = 7'b0010011, AUIPC = 7'b0010111, OP_IMM_32 = 7'b0011011;
    parameter STORE = 7'b0100011, STORE_FP = 7'b0100111, AMO = 7'b0101111, OP =7'b0110011, LUI = 7'b0110111, OP_32 = 7'b0111011;
    parameter MADD = 7'b1000011, MSUB = 7'b1000111, NMSUB = 7'b1001011, NMADD =7'b1001111, OP_FP = 7'b1010011;
    parameter BRANCH = 7'b1100011, JALR = 7'b1100111, JAL = 7'b1101111, SYSTEM = 7'b1110011;

//funct3 parameterizations
    parameter BEQ = 3'b000, BNE = 3'b001, BLT = 3'b100, BGE = 3'b101, BLTU = 3'b110, BGEU = 3'b111;
    parameter LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101;
    parameter SB = 3'b000, SH = 3'b001, SW = 3'b010;
    parameter ADDI = 3'b000, SLTI = 3'b010, SLTIU = 3'b011, XORI = 3'b100, ORI = 3'b110, ANDI = 3'b111, SLLI = 3'b001, SR = 3'b101;
    parameter ADD = 3'b000, SUB = 3'b000, SLL = 3'b001, SLT = 3'b010, SLTU = 3'b011, XOR = 3'b100, SRL = 3'b101, SRA = 3'b101, OR = 3'b110, AND = 3'b111;
    parameter FENCE = 3'b000;// FENCE.I = 3'b001;
    parameter ECALL = 3'b000, EBREAK = 3'b000, CSRRW = 3'b001, CSRRS = 3'b010, CSRRC = 3'b011, CSRRWI = 3'b101, CSRRSI = 3'b110, CSRRCI = 3'b111;

//funct7 parameterizations
    parameter funct7_default = 7'b0000000, funct7_alt = 7'b0100000;

//Make imm_B and imm_J easier to input
    logic [6:0] imm_Benc1 = {imm_B[12], imm_B[10:5]};
    logic [4:0] imm_Benc2 = {imm_B[4:1], imm_B[11]};
    logic [19:0] imm_Jenc = {imm_J[20], imm_J[10:1], imm_J[11], imm_J[19:12]};




//DUT
processor_no_mem DUT( .regValues(regValues), .command(command), .clk(clk), .reset(reset), .run(run), .done(done));

//drive input

//clk 100MHZ or 10ns clk period
always #5 clk = ~clk;
initial
    begin
    clk = 1'b0;
end


//command struct:
// I-type: {12'd[imm_i], 5'd[rs1], [FUNCT3], 5'd[rd], OP_IMM}
// R-Type: {funct7_default, 5'd[rs2], 5'd[rs1], [funct3], 5'd[rd], OP}
// U-type: {20'd[imm_U], 5'd[rd], OPCODE}
// J-type:  imm_J = 20'd[imm_J]; 
//          {imm_Jenc, 5'd[rd], OPCODE}
// B-type:  imm_B = 12'd[imm_B];    
//          {imm_Benc1, 5'd[rs2], 5'd[rs1], funct3, imm_Benc2, OPCODE}
//stimulus
initial 
    begin 
        //reset processor  
        run = 1'b0;
        reset = 1'b1;
        //1. ADDI x1, x0, 10;
        #20 reset = 1'b0;
        command = {12'd10, 5'd0, ADDI, 5'd1, OP_IMM};
        //2. ADDI x2, x0, -4;
        #40 command = { 12'sd65532, 5'd0, ADDI, 5'd2, OP_IMM};
        //3. ADD x3, x1, x2;
        #40 command = {funct7_default, 5'd2, 5'd1, ADD, 5'd3, OP};
        //4. SUB x4, x1, x2;
        #40 command = {funct7_alt, 5'd1, 5'd2, SUB, 5'd4, OP};
        //5. SLT X5, X2, X1;
        #40 command = {funct7_default, 5'd1, 5'd2, SLT, 5'd5, OP};
        //6. SLTU X6, X0, X2;
        #40 command = {funct7_default, 5'd2, 5'd0, SLTU, 5'd6, OP};
        //7. AND X7, X1, X3;
        #40 command = {funct7_default, 5'd3, 5'd1, AND, 5'd7, OP};
        //8. OR X8, X1, X3;
        #40 command = {funct7_default, 5'd3, 5'd1, OR, 5'd8, OP};
        //9. XOR X9, X1, X3;
        #40 command = {funct7_default, 5'd3, 5'd1, XOR, 5'd9, OP};
        //10. SLL X10, X2, X7
        #40 command = {funct7_default, 5'd7, 5'd2, SLL, 5'd10, OP};
        //11. SRL X11, X2, X7;
        #40 command = {funct7_default, 5'd7, 5'd2, SRL, 5'd11, OP};
        //12. SRA X12, X2, X7
        #40 command = {funct7_alt, 5'd7, 5'd2, SRA, 5'd12, OP};

    end

//collection
initial
    begin
    fail = 0;
    failNum = 0;
    //1. X1 = 10;
    #60 if( regValues[1] != 10)
            begin
                $display("fail test 1");
                fail = 1'b1;
                failNum++;
            end
    //2. X2 = -4;
    #40 if( regValues[2] != -4)
        begin
            $display("fail test 2");
            fail = 1'b1;
            failNum++;
        end

    //3. X3 = 6;
    #40 if( regValues[3] != 6)
        begin
            $display("fail test 3");
            fail = 1'b1;
            failNum++;
        end

    //4. X4 = 14;
    #40 if( regValues[4] != 14)
        begin
            $display("fail test 4");
            fail = 1'b1;
            failNum++;
        end
    //5. X5 = 1;
    #40 if( regValues[5] != 1)
        begin
            $display("fail test 5");
            fail = 1'b1;
            failNum++;
        end
    //6. X6 = 1;
    #40 if( regValues[6] != 1)
        begin
            $display("fail test 6");
            fail = 1'b1;
            failNum++;
        end
    //7. X7 = 2;
    #40 if( regValues[7] != 2)
        begin
            $display("fail test 7");
            fail = 1'b1;
            failNum++;
        end
    //8. X8 = 14;
    #40 if( regValues[8] != 14)
        begin
            $display("fail test 8");
            fail = 1'b1;
            failNum++;
        end
    //9. X9 = 12;
    #40 if( regValues[9] != 12)
        begin
            $display("fail test 9");
            fail = 1'b1;
            failNum++;
        end
    //10. X10 = -16;
    #40 if( regValues[10] != -16)
        begin
            $display("fail test 10");
            fail = 1'b1;
            failNum++;
        end
    //11. X11 = 1073741823;
    #40 if( regValues[11] != 1073741823)
        begin
            $display("fail test 11");
            fail = 1'b1;
            failNum++;
        end
    //12. X12 = -1;
    #40 if( regValues[12] != -1)
        begin
            $display("fail test 12");
            fail = 1'b1;
            failNum++;
        end
    
    if(fail == 1)
        $display("Failed %0d tests!", failNum);
    else
        $display("All tests passed!");
    end

endmodule