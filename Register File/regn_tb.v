`timescale 1ns / 100ps

module regn_tb;

//data types
reg clk, enable, reset;
reg [31:0] din;
wire [31:0] dout;
//instantiation
regn x1( din, clk, enable, reset, dout);

//stimulus generation

//clk generation
initial begin
    clk = 1'b0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    //setup
    enable = 1'b0;
    reset = 1'b1;
    #10 din = 32'h00000000;

    //1. Does enable properly block?
    #10 reset = 1'b0;
    din = 32'h00000001;
    //2. Does enable enable
    #10 enable = 1'b1;
    //3. check for store
    #10 enable = 1'b0;
    din = 32'h00000000;
    //4. Do we reset properly?
    #10 reset = 1'b1;
    //5. wait
    #10 din = 32'h1111111111;
    
end

endmodule