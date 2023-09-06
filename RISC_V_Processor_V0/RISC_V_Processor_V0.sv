module RISC_V_Processor_V0( 
    input [31:0] command,
    input clk, reset, run,
    output reg done,
    output reg signed [31:0] regValues [39:0]);
    

    //instantiations
    wire [31:0] IR_out, imm, dIn, result_dIn, op1_dOut; //dIn is the main internal bus
    reg [31:0] gpr_enable;
    wire signed [31:0] mux_dIn [39:0];
    reg [2:0] opSel;
    reg op1_enable, result_enable, IR_enable;
    reg [5:0] mux_sel;

    wire [7:0] funct7;
    wire [4:0] rs2, rs1, rd;
    wire [2:0] funct3;
    wire [6:0] opcode;
    wire [31:0] rd_decoded;
    reg alt_operator; //used for allowing SUB, SRAI, SRA and other operators relying on IR[30] to differentiate from a standard operator.
    reg branchMode;
    wire [31:0] result_dOut;

    assign mux_dIn[32] = result_dOut;
    //registers
    regn IR(.din(command), .clk(clk), .enable(IR_enable), .reset(reset), .dout(IR_out));
    regn op1( .din(dIn), .clk(clk), .enable(op1_enable), .reset(reset), .dout(op1_dOut));
    regn result( .din(result_dIn), .clk(clk), .reset(reset), .enable(result_enable) , .dout(result_dOut));
    regn x0(.din(dIn), .clk(clk), .reset(reset), .enable(gpr_enable[0]), .dout(mux_dIn[0]));

    //PC
    logic PC_enable;
    reg [31:0] PC_dOut;
    reg PC_increment;
    always @ (posedge clk)
        begin : PCBlock
            if(reset)
                PC_dOut <= 32'h0000;
            else if(PC_enable == 1'b1)
                PC_dOut <= dIn;
            else if(PC_increment == 1'b1)
                PC_dOut <= PC_dOut + 4;
        end

    //register file
    genvar i1;
    generate 
        for(i1 = 1; i1<32; i1 = i1 +1 ) begin : RFileFor
            regn x(.din(dIn), .clk(clk), .reset(reset), .enable(gpr_enable[i1]), .dout(mux_dIn[i1]));

        end
    endgenerate

    //decoder
    dec5to32 decoder(.dIn(rd), .dOut(rd_decoded));

    //Load Store Unit:
    reg [31:0] addressIn;
    reg [31:0] dStore;
    reg addressInEn;
    reg dStoreEn;
    reg wren;
    LoadStoreUnit loadStore ( .address(addressIn), .clk(clk), .wren(wren), .funct3(funct3), .dIn(dStore), .dOut(mux_dIn[39]));

    //control signals for load/store register inputs;
    always @ (*)
        begin
            if(addressInEn)
                addressIn = dIn;
            if(dStoreEn)
                dStore = dIn;
        end

    //ALU
    alu ALU(.opSel(opSel), .op1(op1_dOut), .op2(dIn), .result(result_dIn) , .alt_operator(alt_operator), .branchMode(branchMode));

    //MUX (internal processor bus)
    assign mux_dIn[38] = {PC_dOut};
    assign dIn = mux_dIn[mux_sel];

    //decoding
    assign funct7 = IR_out[31:25];
    assign rs2 = IR_out[24:20];
    assign rs1 = IR_out[19:15];
    assign funct3 = IR_out[14:12];
    assign rd = IR_out[11:7];
    assign opcode = IR_out[6:0];

    //OPCODE PARAMETERIZATIONS
    parameter LOAD = 7'b0000011, LOAD_FP = 7'b0000111, MISC_MEM = 7'b0001111, OP_IMM = 7'b0010011, AUIPC = 7'b0010111, OP_IMM_32 = 7'b0011011;
    parameter STORE = 7'b0100011, STORE_FP = 7'b0100111, AMO = 7'b0101111, OP =7'b0110011, LUI = 7'b0110111, OP_32 = 7'b0111011;
    parameter MADD = 7'b1000011, MSUB = 7'b1000111, NMSUB = 7'b1001011, NMADD =7'b1001111, OP_FP = 7'b1010011;
    parameter BRANCH = 7'b1100011, JALR = 7'b1100111, JAL = 7'b1101111, SYSTEM = 7'b1110011;

    //funct3 parameterizations
    parameter BEQ = 3'b000, BNE = 3'b001, BLT = 3'b100, BGE = 3'b101, BLTU = 3'b110, BGEU = 3'b111;
    parameter LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101;
    parameter SB = 3'b000, SH = 3'b001, SW = 3'b010;
    parameter ADDI = 3'b000, SLTI = 3'b010, SLTIU = 3'b011, XORI = 3'b100, ORI = 3'b110, ANDI = 3'b111, SLLI = 3'b001, SRLI = 3'b101;
    parameter ADD = 3'b000, SUB = 3'b000, SLL = 3'b001, SLT = 3'b010, SLTU = 3'b011, XOR = 3'b100, SRL = 3'b101, SRA = 3'b101, OR = 3'b110, AND = 3'b111;
    parameter FENCE = 3'b000;// FENCE.I = 3'b001;
    parameter ECALL = 3'b000, EBREAK = 3'b000, CSRRW = 3'b001, CSRRS = 3'b010, CSRRC = 3'b011, CSRRWI = 3'b101, CSRRSI = 3'b110, CSRRCI = 3'b111;

    //immediate constants 
    assign mux_dIn[33] = {{21{IR_out[31]}}, IR_out[30:20]}; // imm_I
    assign mux_dIn[34] = {{20{IR_out[31]}}, IR_out[30:25], IR_out[11:7]}; // imm_S
    assign mux_dIn[35] = {{19{IR_out[31]}}, IR_out[7], IR_out[30:25], IR_out[11:8], 1'b0}; //imm_B
    assign mux_dIn[36] = {IR_out[31:12], {12{1'b0}}}; //imm_U
    assign mux_dIn[37] = {{12{IR_out[31]}}, IR_out[19:12], IR_out[20], IR_out[30:21], 1'b0}; //imm_J

    parameter imm_I = 6'd33, imm_S = 6'd34, imm_B = 6'd35, imm_U = 6'd36, imm_J = 6'd37, result_select = 6'd32;
    parameter PC_select =6'd38;

    //FSM (control system)
    reg [4:0] state;
    reg [4:0] nextState;

    //drive state changes
    always @(posedge clk)
        begin
            if(reset)
            state <= 0;
            else
            state <= nextState;
        end

    //FSM state table
    always @(*)
    begin
        if(done == 1'b1)
        begin
            nextState = 0;
        end
        else
            nextState = state + 1;
    end

    //Output logic
    always @(*)
    begin
        done = 0;
        IR_enable = 0;
        op1_enable = 0;
        mux_sel = 0;
        result_enable = 0;
        opSel = 0;
        gpr_enable = 0;
        PC_increment = 0;
        alt_operator = 0;
        PC_enable = 0;
        branchMode = 0;
        wren = 0;
        dStoreEn = 0;
        addressInEn = 0;

        case(state)

            0: begin
                IR_enable = 1;
            end

            1: begin
                case(opcode)
                    OP_IMM: begin
                        PC_increment = 1'b1;
                        op1_enable = 1'b1;
                        mux_sel = imm_I;
                        end
                    OP:  begin
                        PC_increment = 1'b1;
                        op1_enable = 1'b1;
                        mux_sel = rs2;
                    end
                    LUI: begin
                        PC_increment = 1'b1;
                        gpr_enable = rd_decoded;
                        mux_sel = imm_U;
                        done = 1'b1;
                    end
                    AUIPC: begin
                        op1_enable = 1'b1;
                        mux_sel = PC_select;
                    end
                    JAL: begin
                        op1_enable = 1'b1;
                        mux_sel = PC_select; 
                    end
                    JALR: begin
                        PC_increment = 1'b1;
                        op1_enable = 1'b1;
                        mux_sel = rs1; 
                    end
                    BRANCH: begin
                        op1_enable = 1'b1;
                        mux_sel = rs1;
                    end
                    STORE: begin
                        op1_enable = 1'b1;
                        mux_sel = imm_S;

                    end
                    LOAD: begin
                        op1_enable = 1'b1;
                        mux_sel = imm_I;
                    end
                endcase
            end

            2: begin
            case(opcode)
                    OP_IMM: begin
                        mux_sel = rs1;
                        result_enable = 1'b1;
                        opSel = funct3;
                        if( (funct3 == SRLI) && (IR_out[30] == 1))
                            alt_operator = 1'b1;
                        end
                    OP:  begin
                        mux_sel = rs1;
                        result_enable = 1'b1;
                        opSel = funct3;
                        if( ( (funct3 == SRA) || (funct3 == SUB) ) && (IR_out[30] == 1) )
                            alt_operator = 1'b1;
                    end
                    AUIPC: begin
                        PC_increment = 1'b1;
                        mux_sel = imm_U;
                        opSel = ADD;
                        result_enable = 1'b1;
                    end
                    JAL: begin
                        PC_increment = 1'b1;
                        mux_sel = imm_J;
                        opSel = ADD;
                        result_enable = 1'b1;
                    end
                    JALR: begin
                        mux_sel = imm_I;
                        opSel = ADD;
                        result_enable = 1'b1;

                    end
                    BRANCH: begin
                        mux_sel = rs2; 
                        opSel = funct3;
                        branchMode = 1;
                        result_enable = 1'b1;
                    end
                    STORE: begin
                        mux_sel = rs1;
                        opSel = ADD;
                        result_enable = 1'b1;
                    end
                    LOAD: begin
                        mux_sel = rs1;
                        opSel = ADD;
                        result_enable = 1'b1;
                    end
                endcase
            end

            3: begin
                case(opcode)
                    OP_IMM: begin
                        gpr_enable = rd_decoded;
                        mux_sel = result_select;
                        done = 1'b1;
                        end

                    OP:  begin
                        gpr_enable = rd_decoded;
                        mux_sel = result_select;
                        done = 1'b1;

                    end
                    AUIPC: begin
                        gpr_enable = rd_decoded;
                        mux_sel = result_select;
                        done = 1'b1;
                    end
                    JAL: begin
                        mux_sel = PC_select;
                        gpr_enable = rd_decoded;
                    end
                    JALR: begin
                        mux_sel = PC_select;
                        gpr_enable = rd_decoded;

                    end
                    BRANCH: begin
                        if(result_dOut == 0)
                            begin
                                PC_increment = 1'b1;
                                done = 1'b1;
                            end
                        else
                            begin
                                op1_enable = 1'b1;
                                mux_sel = imm_B;
                            end

                    end
                    STORE: begin
                        mux_sel = result_select;
                        addressInEn = 1'b1;
                    end
                    LOAD: begin
                        mux_sel = result_select; 
                        addressInEn = 1'b1;
                    end
                endcase
            end

            4: begin
                case(opcode)
                    JAL: begin
                        mux_sel = result_select; 
                        PC_enable = 1'b1;
                        done = 1'b1;

                    end
                    JALR: begin
                        mux_sel = result_select; 
                        PC_enable = 1'b1;
                        done = 1'b1;

                    end
                    BRANCH: begin
                        mux_sel = PC_select;
                        opSel = ADD;
                        result_enable = 1'b1;

                    end
                    STORE: begin
                        mux_sel = rs2;
                        dStoreEn = 1'b1;
                        wren = 1'b1;
                    end
                    LOAD: begin
                        mux_sel = 39;
                    end
                    default: done = 1'b1;

                    endcase
                end
            5: begin
                case(opcode)
                    BRANCH: begin
                        mux_sel = result_select;
                        PC_enable = 1'b1;
                        done = 1'b1;
                    end
                    STORE: begin
                        done = 1'b1;
                    end
                    LOAD: begin
                        mux_sel = 39; 
                        gpr_enable = rd_decoded;
                        done = 1'b1;
                    end
                endcase
            end
        endcase
    end


assign regValues = mux_dIn;


endmodule