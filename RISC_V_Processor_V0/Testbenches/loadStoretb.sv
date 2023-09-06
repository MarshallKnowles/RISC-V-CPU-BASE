`timescale 1ns/1ns

module loadStoretb();

//initalize data types
logic signed [31:0] regValues [39:0];
logic [31:0]command;
logic clk, reset, run, done;
logic [11:0] imm_B;
logic [19:0] imm_J;
logic [11:0] imm_S;

//scoreboard data
logic fail;
integer failNum;
integer testNum;
parameter totalTests = 14;

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
    wire [6:0] imm_Senc1;
    wire [4:0] imm_Senc2;

    assign imm_Senc2 = imm_S[4:0];
    assign imm_Senc1 = imm_S[11:5];


//DUT
RISC_V_Processor_V0 DUT( .regValues(regValues), .command(command), .clk(clk), .reset(reset), .run(run), .done(done));

//drive input

//clk 100MHZ or 10ns clk period
always #5 clk = ~clk;   
initial
    begin
    clk = 1'b1;
end


//command struct:
// I-type: {12'd[imm_i], 5'd[rs1], [FUNCT3], 5'd[rd], OP_IMM}
// R-Type: {funct7_default, 5'd[rs2], 5'd[rs1], [funct3], 5'd[rd], OP}
// U-type: {20'd[imm_U], 5'd[rd], OPCODE}
// J-type:  imm_J = 20'd[imm_J]; 
//          {imm_Jenc, 5'd[rd], OPCODE}
// B-type:  imm_B = 12'd[imm_B];    
//          {imm_Benc1, 5'd[rs2], 5'd[rs1], funct3, imm_Benc2, OPCODE}
// S-type:  {imm_Senc1, 5'd[rs2], 5'd[rs1], funct3, imm_Senc2, STORE}
//stimulus
initial 
    begin 
        //reset processor  
        run = 1'b0;
        reset = 1'b1;
        //1. ADDI x1, x0, 12h'def;
        #20 reset = 1'b0;
        command = {12'h4ef, 5'd0, ADDI, 5'd1, OP_IMM};
        //2. ADDI x2, x0, f;
        #40 command = { 12'hf, 5'd0, ADDI, 5'd2, OP_IMM};
        //3. LUI x3, 20'habcde;
        #40 command = {20'habcde, 5'd3, LUI};
        //4. ADD x4, x3, x1;
        #20 command = {funct7_default, 5'd1, 5'd3, ADD, 5'd4, OP};
        //5. SW x2, x4, 0;
        #10 imm_S = 0;
        #30 command = {imm_Senc1, 5'd4, 5'd2, SW, imm_Senc2, STORE};
        //6. SH x2, x4, 1;
        #10 imm_S = 1;
        #50 command = {imm_Senc1, 5'd4, 5'd2, SH, imm_Senc2, STORE};
        //7. SB r2, r4, 2;
        #10 imm_S = 2;
        #50 command = {imm_Senc1, 5'd4, 5'd2, SB, imm_Senc2, STORE};
        //8. LW x5, x2, 0;
        #60 command = {12'd0, 5'd2, LW, 5'd5, LOAD};
        //9. LH x6, x2, 0;
        #60 command = {12'd0, 5'd2, LH, 5'd6, LOAD};
        //10. LB x7, x2, 0;
        #60 command = {12'd0, 5'd2, LB, 5'd7, LOAD};
        //11. LW x8, x2, 1;
        #60 command = {12'd1, 5'd2, LW, 5'd8, LOAD};
        //12. LW x9, x2, 2;
        #60 command = {12'd2, 5'd2, LW, 5'd9, LOAD};
        //13. LHU x10 x2, 0;
        #60 command = {12'd0, 5'd2, LHU, 5'd10, LOAD};
        //14. LBU x11, x2, 0;
        #60 command = {12'd0, 5'd2, LBU, 5'd11, LOAD};

    end

//collection
initial
    begin
    fail = 0;
    failNum = 0;
    testNum = 1;
    //1. X1 = def;
    #60 if( regValues[1] != 32'h4ef)
            begin
                $display("fail test 1");
                fail = 1'b1;
                failNum++;
            end
            testNum++;
    //2. X2 = f;
    #40 if( regValues[2] != 32'hf)
        begin
            $display("fail test 2");
            fail = 1'b1;
            failNum++;
        end
    testNum++;

    //3. X3 = abcde000;
    #20 if( regValues[3] != 32'habcde000)
        begin
            $display("fail test 3");
            fail = 1'b1;
            failNum++;
        end
    testNum++;
    //4. X4 = abcdedef;
    #40 if( regValues[4] != 32'habcde4ef)
        begin
            $display("fail test 4");
            fail = 1'b1;
            failNum++;
        end
    testNum++;
    //5. X5 = abcdedef;(BIG DELAY)
    #240 if( regValues[5] != 32'habcde4ef)
        begin
            $display("fail test 5");
            fail = 1'b1;
            failNum++;
        end
    testNum++;
    //6. X6 = ffffedef;
    #60 if( regValues[6] != 32'hffffe4ef)
        begin
            $display("fail test 6");
            fail = 1'b1;
            failNum++;
        end
        testNum++;
    //7. X7 = ffffffef;
    #60 if( regValues[7] != 32'hffffffef)
        begin
            $display("fail test 7");
            fail = 1'b1;
            failNum++;
        end
        testNum++;
    //8. X8 = 0000edef;
    #60 if( regValues[8] != 32'h0000e4ef)
        begin
            $display("fail test 8");
            fail = 1'b1;
            failNum++;
        end
        testNum++;
    //9. X9 = 000000ef;
    #60 if( regValues[9] != 32'h000000ef)
        begin
            $display("fail test 9");
            fail = 1'b1;
            failNum++;
        end
        testNum++;
    //10. X10 = 0000edef;
    #60 if( regValues[10] != 32'h0000e4ef)
        begin
            $display("fail test 10");
            fail = 1'b1;
            failNum++;
        end
        testNum++;
    //11. X11 = 000000ef;
    #60 if( regValues[11] != 32'h000000ef)
        begin
            $display("fail test 11");
            fail = 1'b1;
            failNum++;
        end
        testNum++;
    if(fail == 1)
        $display("Failed %0d tests!", failNum);
    else
        $display("All tests passed!");
        $stop;
        $finish;
    end
endmodule