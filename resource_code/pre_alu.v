module pre_alu(
    input [31:0] ex_rdata_a,
    input [31:0] ex_rdata_b,
    input [31:0] mem_wb_dout,
    input control_rdata_a,
    input control_rdata_b,
    output wire [31:0] rdata_a,
    output wire [31:0] rdata_b
);

assign rdata_a = (control_rdata_a == 1'b1)?mem_wb_dout:ex_rdata_a;
assign rdata_b = (control_rdata_b == 1'b1)?mem_wb_dout:ex_rdata_b;
/*
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
*/    

endmodule 