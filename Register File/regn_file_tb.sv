`timescale 1ns / 100ps

module regn_file_tb;

//data type declarations
logic [31:0] din, reset, enable;
logic [4:0] select;
logic clk;
logic [31:0] dout;
logic valid;
logic [31:0] [31:0]goldenOutput;
//instantiaion
regn_file dut( .din(din) , .reset(reset) , .enable(enable) , .select(select) , .clk(clk) , .dout(dout) );

// generation

//clk
initial
    begin
    clk = 1'b0;
    forever
        begin
        #5 clk = ~clk;
        end
    end

//input data
integer i;
integer j;
initial 
begin
    for(i = 0; i<32; i = i + 1)
        begin
        goldenOutput[i] = $urandom_range(2**30);
        din = goldenOutput[i];
        enable = (2**i);
        #10;
        end



    //output collection
    for(j = 0; j < 32; j = j + 1)
    begin
        select = j;
        #1;
        if(dout == goldenOutput[j])
            valid = 1;
        else
            valid = 0;
        #9;
    end

    $stop;

end



endmodule