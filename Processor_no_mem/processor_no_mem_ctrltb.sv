`timescale 1ns/1ns

module processor_no_mem_tb();

//initalize data types
logic signed [31:0] regValues [38:0];
logic [31:0]command;
logic clk, reset, run, done;
logic [12:0] imm_B;
logic [20:0] imm_J;

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
    wire [6:0] imm_Benc1;
    wire [4:0] imm_Benc2;
    wire [19:0] imm_Jenc;

    assign imm_Benc1 = {imm_B[12], imm_B[10:5]};
    assign imm_Benc2 = {imm_B[4:1], imm_B[11]};
    assign imm_Jenc = {imm_J[20], imm_J[10:1], imm_J[11], imm_J[19:12]};

//DUT
processor_no_mem DUT( .regValues(regValues), .command(command), .clk(clk), .reset(reset), .run(run), .done(done));

//drive input

//clk 100MHZ or 10ns clk period
initial
    begin
    clk = 1'b0;
    forever begin
        #5 clk = ~clk;
    end
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
        #20
        //1. ADDI x1, x0, 10;
        reset = 1'b0;
        command = {12'd16, 5'd0, ADDI, 5'd1, OP_IMM};
        #40
        //2. LUI x2, 16
        command = {20'd16, 5'd2, LUI};
        #20
        //3. ADD X3, X1, X2
        command = {funct7_default, 5'd2, 5'd1, ADD, 5'd3, OP};
        #40
        //4. AUIPC X4, 4
        command = {20'd4, 5'd4, AUIPC};
        #20
        //5. JAL X5, 16
        imm_J = 20'd16;
        #20
        command = {imm_Jenc, 5'd5, JAL};
        #50
        //6. JALR X6, X1, 24
        command = {12'd24, 5'd1, ADD, 5'd6, JALR};
        #40
        //7. BEQ X1, X2, 200
        imm_B = 12'd200;    
        #10
        command = {imm_Benc1, 5'd2, 5'd1, BEQ, imm_Benc2, BRANCH};
        #30
        //8. BNE X1, X2, 20
        imm_B = 12'd20;
        #10
        command = {imm_Benc1, 5'd2, 5'd1, BNE, imm_Benc2, BRANCH};
        #60
        //9. BLT x1, x2, 20
        command = {imm_Benc1, 5'd2, 5'd1, BLT, imm_Benc2, BRANCH};
        #60
        //10. BGE x1, x2, 20
        command = {imm_Benc1, 5'd2, 5'd1, BGE, imm_Benc2, BRANCH};
        #60;
        
    end

//collection
initial
    begin
    fail = 0;
    failNum = 0;
    //1. X1 = 16;
    #60 if( regValues[1] != 16)
            begin
                $display("fail test 1");
                fail = 1'b1;
                failNum++;
            end
    //2. X2 = 65536;
    #20 if( regValues[2] != 65536)
            begin
                $display("fail test 2");
                fail = 1'b1;
                failNum++;
            end
    //3. X3 = 65552;
    #40 if( regValues[3] != 65552)
            begin
                $display("fail test 3");
                fail = 1'b1;
                failNum++;
            end
    //4. X4 = 16396;
    #40 if( regValues[4] != 16396)
            begin
                $display("fail test 4");
                fail = 1'b1;
                failNum++;
            end
    //5. X5 = 20, PC = 32;
    #50 if( (regValues[5] != 20) || (regValues[38] != 32) )
            begin
                $display("fail test 5");
                fail = 1'b1;
                failNum++;
            end
    //6. X6 = 36, PC = 40;
    #50 if( (regValues[6] != 36) || (regValues[38] != 40) )
            begin
                $display("fail test 6");
                fail = 1'b1;
                failNum++;
            end
    //7. PC = 44;
    #40 if(regValues[38] != 44)
            begin
                $display("fail test 7");
                fail = 1'b1;
                failNum++;
            end
    //8. PC = 64;
    #60 if(regValues[38] != 64)
            begin
                $display("fail test 8");
                fail = 1'b1;
                failNum++;
            end
    //9. PC = 84;
    #60 if(regValues[38] != 84)
            begin
                $display("fail test 9");
                fail = 1'b1;
                failNum++;
            end
    //10. PC = 88;
    #60 if(regValues[38] != 88)
            begin
                $display("fail test 10");
                fail = 1'b1;
                failNum++;
            end
    
    if(fail == 1)
        $display("Failed %0d tests!", failNum);
    else
        $display("All tests passed!");
    end

endmodule