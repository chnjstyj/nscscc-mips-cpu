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
        #2; clk = ~clk;
    end
end

initial begin  
    rst = 0;
    #10;
    rst = 1;
    #10000000;
    rst = 0;
end
endmodule 