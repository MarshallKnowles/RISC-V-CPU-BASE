`timescale 1ns/100ps


module LoadStoreUnit_tb();

//Scoreboard
integer numFail = 0;
parameter numTests = 10;
parameter delay = 10;
integer testnum = 0;

//DUT I/O:
reg [31:0] address, dIn;
wire [31:0] dOut;
reg clk = 0;
reg wren;
reg [2:0] funct3;

//DUT
LoadStoreUnit DUT ( address, clk, wren, funct3, dIn, dOut);
	
//parameterize the Load and Stores
parameter LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LHU = 3'b101;
parameter SB = 3'b000, SH = 3'b001, SW = 3'b010;

//Stimulus:
//100Mhz clk
initial clk = 1'b1;
always #5 clk = ~clk;

//tests
initial
    begin
        //Tests
        //1.
        address <= 1;
        dIn <= 32'hf0f0f0f0;
        wren <= 1'b1;
        funct3 <= SW;
        testnum <= testnum + 1;
        #delay
        //2.
        address <= 2;
        dIn <= 32'hffffffff;
        wren <= 1'b1;
        funct3 <= SH;
        testnum <= testnum + 1;
        #delay
        //3.
        address <= 3;
        dIn <= 32'hffafffaf;
        wren <= 1'b1;
        funct3 <= SB;
        testnum <= testnum + 1;
        #delay
        //4.
        address <= 1;
        dIn <= 32'd40;
        wren <= 1'b0;
        funct3 <= LW;
        testnum <= testnum + 1;
        #delay
        //5.
        address <= 1;
        dIn <= 50;
        wren <= 0;
        funct3 <= LH;
        testnum <= testnum + 1;
        #delay
        //6. 
        address <= 1;
        dIn <= 60;
        wren <= 0;
        funct3 <= LB;
        testnum <= testnum + 1;
        #delay
        //7. 
        address <= 1;
        dIn <= 70;
        wren <= 0;
        funct3 <= LHU;
        testnum <= testnum + 1;
        #delay
        //8. 
        address <= 1;
        dIn <= 80;
        wren <= 0;
        funct3 <= LBU;
        testnum <= testnum + 1;
        #delay
        //9. 
        address <= 2;
        dIn <= 90;
        wren <= 0;
        funct3 <= LW;
        testnum <= testnum + 1;
        #delay
        //10. 
        address <= 3;
        dIn <= 100;
        wren <= 0;
        funct3 <= LW;
        testnum <= testnum + 1;
    end


//collection
initial
    begin
        numFail = 0;
        #delay
        //1.
        if(dOut != 32'hXXXXXXXX)
            begin
                numFail = numFail + 1;
                $display( "Test 1 failed");
            end
        #delay
        //2.
        if(dOut != 32'hXXXXXXXX)
            begin
                numFail = numFail + 1;
                $display( "Test 2 failed");
            end
        #delay
        //3.
        if(dOut != 32'hXXXXXXXX)
            begin
                numFail = numFail+1;
                $display( "Test 3 failed");
            end
        #delay
        //4.
        if(dOut == 32'hXXXXXXXX)
            begin
                numFail= numFail +1;
                $display( "Test 4 failed");
            end
        #delay
        //5.
        if(dOut != 32'hfffff0f0)
            begin
                numFail= numFail +1;
                $display( "Test 5 failed");
            end
        #delay
        //6.
        if(dOut != 32'hfffffff0)
            begin
                numFail= numFail +1;
                $display( "Test 6 failed");
            end
        #delay
        //7.
        if(dOut != 32'h0000f0f0)
            begin
                numFail= numFail +1;
                $display( "Test 7 failed");
            end
        #delay
        //8.
        if(dOut != 32'h000000f0)
            begin
                numFail= numFail +1;
                $display( "Test 8 failed");
            end
        #delay
        //9.
        if(dOut != 32'h0000ffff)
            begin
                numFail= numFail +1;
                $display( "Test 9 failed");
            end
        #delay
        //10.
        if(dOut != 32'h000000af)
            begin
                numFail= numFail +1;
                $display( "Test 10 failed");
            end
        #delay
        if(numFail != 0)
            $display("%d tests failed", numFail);
        else
            $display("All tests passed");
			$stop;
			$finish;
    end


endmodule