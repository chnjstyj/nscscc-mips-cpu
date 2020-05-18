module pre_alu(
    input [31:0] ex_rdata_a,
    input [31:0] ex_rdata_b,
    input [31:0] mem_wb_dout,
    input control_rdata_a,
    input control_rdata_b,
    output reg [31:0] rdata_a,
    output reg [31:0] rdata_b
);

always @(*) begin 
    if(control_rdata_a)
        rdata_a <= mem_wb_dout;
    else
        rdata_a <= ex_rdata_a;
end 

always @(*) begin 
    if(control_rdata_b) 
        rdata_b <= mem_wb_dout;
    else 
        rdata_b <= ex_rdata_b;
end 
    

endmodule 