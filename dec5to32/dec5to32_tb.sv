`timescale 1ns/100ps

module dec5to32_tb;

//data type declarations
    logic [4:0] dIn;
    logic [31:0] dOut;
    logic [31:0] goldenOut;
    logic valid;

//dut
    dec5to32 dut( .dIn(dIn), .dOut(dOut));

//stimulus generation

integer i;
integer j;

initial
    begin
        for(i = 0; i <32; i = i + 1)
        begin
            //input data
            dIn = i;
            goldenOut = 2**i;

            #5;
            
            //collect data
            if(dOut != goldenOut)
            begin
                $display("fail!");
                valid = 0;
            end
            else
            begin
                $display("succces!");
                valid = 1;
            end
        end
    end

endmodule