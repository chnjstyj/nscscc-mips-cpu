`timescale 1ns / 1ps
module top_tb;

//inputs 
    reg clk;
    reg rst;

    
top top(
    .clk(clk),
    .rst(rst)
);

initial begin
    clk = 0;
end

always @(*) begin
    forever begin
        #10; clk = ~clk;
    end
end

initial begin  
    rst = 0;
    #100;
    rst = 1;
    #1000;
    rst = 0;
end
endmodule 