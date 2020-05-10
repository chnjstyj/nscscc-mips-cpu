module top_tb;

//inputs 
    reg clk;
    reg rst;

    
top top(
    .clk(clk),
    .rst(rst)
);