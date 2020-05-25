`timescale 1ns / 1ps
module top_tb;

//inputs 
    reg clk;
    reg rom_clk;
    reg rst;

    
top top(
    .clk(clk),
    .rom_clk(rom_clk),
    .rst(rst)
);

initial begin
    clk = 0;
    rom_clk = 0;
end

always @(*) begin
    forever begin
        #20; clk = ~clk;
    end
end

always @(*) begin
    forever begin 
        #2; rom_clk = ~rom_clk;
    end
end

initial begin  
    rst = 0;
    #80;
    rst = 1;
    #10000000;
    rst = 0;
end
endmodule 